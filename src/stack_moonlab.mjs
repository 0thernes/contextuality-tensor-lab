/** Actual pinned Moonlab WASM gates and projective measurements.
 * The adapter rotates Pauli strings into a measured Z; Moonlab does every gate,
 * Born draw and collapse. Structure layout access is tied to PROVENANCE.md.
 * QRNG is a seeded classical software mixer, not quantum hardware entropy.
 */
import {createRequire} from 'node:module';
import {execFileSync} from 'node:child_process';
import {readFileSync, writeFileSync, mkdirSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import {createHash} from 'node:crypto';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const require=createRequire(import.meta.url);
const M=await require(path.join(root,'third_party/moonlab/moonlab.js'))({print:()=>{},printErr:()=>{}});
const seed=Number(process.argv[2]??20261109);
if (!Number.isSafeInteger(seed)||seed<0) throw Error('seed must be a nonnegative safe integer');
const qr=path.join(root,'build',process.platform==='win32'?'stack_qrng.exe':'stack_qrng');
const bytes=Buffer.from(execFileSync(qr,[String(seed),'1048576'],{maxBuffer:2200000}).toString(),'hex');
let cursor=0, gateCount=0, measurements=0;
function u32(){if(cursor+4>bytes.length)throw Error('QRNG stream exhausted');const r=bytes.readUInt32LE(cursor);cursor+=4;return r;}
function unit(){return (u32()>>>8)/16777216;}
function below(n){const limit=0x100000000-(0x100000000%n);let r;do{r=u32();}while(r>=limit);return r%n;}
function assert(x,msg){if(!x)throw Error(msg);}
function state(){const p=M._malloc(256);M.HEAPU8.fill(0,p,p+256);assert(M._quantum_state_init(p,4)===0,'init');return p;}
function free(p){M._quantum_state_free(p);M._free(p);}
function clone(p){const q=M._malloc(256);M.HEAPU8.fill(0,q,q+256);assert(M._quantum_state_clone(q,p)===0,'clone');return q;}
function amplitudes(p){const b=M.HEAPU32[(p+8)>>2]>>3;return Array.from({length:16},(_,i)=>[M.HEAPF64[b+2*i],M.HEAPF64[b+2*i+1]]);}
function gate(name,...args){M[name](...args);gateCount++;}
const single=['XI','IX','XX','IZ','ZI','ZZ','XZ','ZX','YY'];
const local=[[0,1,2,1],[3,4,5,1],[6,7,8,1],[0,3,6,1],[1,4,7,1],[2,5,8,-1]];
const observables=[...single.map(s=>s+'II'),...single.map(s=>'II'+s)];
const contexts=[];
for(let a=0;a<7;a++)for(let b=0;b<7;b++)if(a||b){
  const indices=[], picks=[];let sign=1;
  if(a){indices.push(...local[a-1].slice(0,3));sign*=local[a-1][3];picks.push(a-1);}
  if(b){indices.push(...local[b-1].slice(0,3).map(x=>x+9));sign*=local[b-1][3];picks.push(b-1);}
  contexts.push({indices,sign,local_choices:[a,b]});
}
// An independent bit/phase implementation verifies the complete operator product.
const multiply={II:[0,'I'],IX:[0,'X'],IY:[0,'Y'],IZ:[0,'Z'],XI:[0,'X'],XX:[0,'I'],XY:[1,'Z'],XZ:[3,'Y'],YI:[0,'Y'],YX:[3,'Z'],YY:[0,'I'],YZ:[1,'X'],ZI:[0,'Z'],ZX:[1,'Y'],ZY:[3,'X'],ZZ:[0,'I']};
function pauliProduct(words){let out='IIII',phase=0;for(const word of words){let next='';for(let q=0;q<4;q++){const [p,c]=multiply[out[q]+word[q]];phase+=p;next+=c;}out=next;}return [phase%4,out];}
for(const c of contexts){const [p,w]=pauliProduct(c.indices.map(i=>observables[i]));assert(w==='IIII'&&p===(c.sign===1?0:2),'context operator sign');
  for(const a of c.indices)for(const b of c.indices){assert(JSON.stringify(pauliProduct([observables[a],observables[b]]))===JSON.stringify(pauliProduct([observables[b],observables[a]])),'noncommuting context');}}
function rotate(p,word){let t=-1;for(let q=0;q<4;q++){if(word[q]==='I')continue;if(t<0)t=q;
  if(word[q]==='Y')gate('_gate_s_dagger',p,q);
  if(word[q]==='X'||word[q]==='Y')gate('_gate_hadamard',p,q);}
  for(let q=0;q<4;q++)if(q!==t&&word[q]!=='I')gate('_gate_cnot',p,q,t);return t;}
function unrotate(p,word,t){for(let q=3;q>=0;q--)if(q!==t&&word[q]!=='I')gate('_gate_cnot',p,q,t);
  for(let q=0;q<4;q++){if(word[q]==='X'||word[q]==='Y')gate('_gate_hadamard',p,q);if(word[q]==='Y')gate('_gate_s',p,q);}}
function measure(p,word){const t=rotate(p,word), bit=M._measurement_single_qubit(p,t,unit());measurements++;unrotate(p,word,t);return bit===0?1:-1;}
function expectation(p,word){const q=clone(p),t=rotate(q,word),e=M._measurement_expectation_z(q,t);free(q);return e;}
function directExpectation(amps,word){let a=0,z=0,ys=0;for(let q=0;q<4;q++){if('XY'.includes(word[q]))a|=1<<q;if('ZY'.includes(word[q]))z|=1<<q;if(word[q]==='Y')ys++;}
  const phases=[[1,0],[0,1],[-1,0],[0,-1]];let re=0;
  for(let x=0;x<16;x++){let p=0,v=x&z;while(v){p^=v&1;v>>=1;}const [pr,pi]=phases[(ys+2*p)%4], [ar,ai]=amps[x], [br,bi]=amps[x^a];re+=br*(pr*ar-pi*ai)+bi*(pr*ai+pi*ar);}return re;}
function prepare(kind,component=0){const p=state();
  if(kind==='all_plus'){for(let q=0;q<4;q++)gate('_gate_hadamard',p,q);}
  if(kind==='ghz'){gate('_gate_hadamard',p,0);for(let q=1;q<4;q++)gate('_gate_cnot',p,0,q);}
  if(kind==='cross_square_bells'){gate('_gate_hadamard',p,0);gate('_gate_hadamard',p,1);gate('_gate_cnot',p,0,2);gate('_gate_cnot',p,1,3);}
  if(kind==='seeded_complex'){for(let layer=0;layer<3;layer++){for(let q=0;q<4;q++){gate('_gate_ry',p,q,6.283185307179586*unit());gate('_gate_rz',p,q,6.283185307179586*unit());}for(let q=0;q<3;q++)gate('_gate_cnot',p,q,q+1);}}
  if(kind==='maximally_mixed_ensemble'){for(let q=0;q<4;q++)if(component&(1<<q))gate('_gate_pauli_x',p,q);}
  return p;}
let oracleError=0,repeatFailures=0,signMutationRejections=0;
const rows=[];
for(const kind of ['zero','all_plus','ghz','cross_square_bells','seeded_complex','maximally_mixed_ensemble']){
  const components=kind==='maximally_mixed_ensemble'?16:1, shots=kind==='maximally_mixed_ensemble'?2:16;
  let trials=0,agreed=0;
  for(let component=0;component<components;component++){
    const p=prepare(kind,component), amps=amplitudes(p);
    for(const word of observables){oracleError=Math.max(oracleError,Math.abs(expectation(p,word)-directExpectation(amps,word)));const q=clone(p),one=measure(q,word),two=measure(q,word);if(one!==two)repeatFailures++;free(q);}
    for(const c of contexts)for(let shot=0;shot<shots;shot++){
      const q=clone(p);let product=1;const order=[...c.indices];
      for(let j=order.length-1;j>0;j--){const k=below(j+1);[order[j],order[k]]=[order[k],order[j]];}
      for(const i of order)product*=measure(q,observables[i]);free(q);trials++;if(product===c.sign)agreed++;
      if(product!==-c.sign)signMutationRejections++;
    }free(p);
  }rows.push({preparation:kind,components,shots_per_context_per_component:shots,trials,agreed});assert(trials===agreed,kind+' context identity failed');
}
// Uniform context sampling is part of the executable QRNG workload, not just seeding.
const sampled=Array(48).fill(0);let sampledAgreed=0;
const sampleState=prepare('seeded_complex');
for(let shot=0;shot<4096;shot++){const index=below(48),c=contexts[index],q=clone(sampleState);sampled[index]++;let product=1;for(const i of c.indices)product*=measure(q,observables[i]);sampledAgreed+=Number(product===c.sign);free(q);}free(sampleState);
assert(oracleError<1e-12&&repeatFailures===0&&sampledAgreed===4096,'measurement oracle/repeat/sampling');
// The same native gate engine prepares the QGTL state and central-difference derivatives.
const parameters=[0.37,0.81,1.23,1.87,-0.43,0.29,0.61,-0.71];
function paramState(values){const p=state();for(let q=0;q<4;q++){gate('_gate_ry',p,q,values[q]);gate('_gate_rz',p,q,values[q+4]);}
  gate('_gate_cnot',p,0,2);gate('_gate_cnot',p,1,3);gate('_gate_cnot',p,2,1);const a=amplitudes(p);free(p);return a;}
const h=1e-5,stateValues=paramState(parameters),tangents=[];
for(let j=0;j<8;j++){const plus=[...parameters],minus=[...parameters];plus[j]+=h;minus[j]-=h;const ap=paramState(plus),am=paramState(minus);tangents.push(ap.map((v,k)=>v.map((x,c)=>(x-am[k][c])/(2*h))));}
mkdirSync(path.join(root,'results'),{recursive:true});
writeFileSync(path.join(root,'results/stack_tangents.json'),JSON.stringify({parameters,step:h,state:stateValues,tangents},null,2)+'\n');
const report={status:'pass',engine:'Pinned Tsotchke Moonlab classical CPU/WASM simulator',qubits:4,observables:18,contexts:48,exact_context_sign_checks:48,
  adapter:'Native Moonlab preparation gates, Pauli-basis rotations, measurement draws and collapse; direct state reads only for independent oracle and QGTL tangents',
  rows,exhaustive_context_trials:rows.reduce((s,r)=>s+r.trials,0),seeded_context_trials:4096,seeded_context_agreed:sampledAgreed,seeded_context_counts:sampled,
  max_pauli_expectation_oracle_error:oracleError,repeated_measurement_failures:repeatFailures,flipped_sign_rejections:signMutationRejections,
  gate_calls:gateCount,projective_measurements:measurements,qrng:{seed,consumed_bytes:cursor,stream_bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex'),classification:'Seeded classical quantum-inspired software mixer; no hardware entropy'},
  wasm_sha256:createHash('sha256').update(readFileSync(path.join(root,'third_party/moonlab/moonlab.wasm'))).digest('hex'),
  mixed_state_scope:'Uniform computational-basis ensemble is I/16. Each of all sixteen components is tested; no density-matrix backend is used.',
  state_independence_scope:'These finite simulations are implementation tests. State independence follows from the exact signed identity products, not from finite sampling.'};
writeFileSync(path.join(root,'results/stack_moonlab.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
