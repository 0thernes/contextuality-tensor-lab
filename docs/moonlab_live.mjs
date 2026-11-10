import {contexts,observables} from './lab.mjs';
let instance;
async function engine(){
  if(!instance){if(typeof globalThis.MoonlabModule!=='function')throw Error('Moonlab script not loaded; serve this page over HTTP.');
    instance=globalThis.MoonlabModule({locateFile:name=>new URL('vendor/moonlab/'+name,import.meta.url).href,print:()=>{},printErr:()=>{}});}
  return instance;
}
export async function simulate({preparation='ghz',shots=32,seed=20261109,onProgress=()=>{}}={}){
  if(!['ghz','cross','plus','complex','mixed'].includes(preparation))throw Error('Invalid preparation');
  if(!Number.isInteger(shots)||shots<1||shots>128)throw Error('Shots must be an integer in 1..128');
  if(!Number.isInteger(seed)||seed<1||seed>4294967295)throw Error('Seed must be in 1..4294967295');
  const M=await engine();let rng=seed>>>0,gates=0,measurements=0,maxError=0,agree=0,trials=0;
  function random(){rng^=rng<<13;rng^=rng>>>17;rng^=rng<<5;return(rng>>>0)/4294967296;}
  function assert(x,s){if(!x)throw Error(s);}
  function state(){const p=M._malloc(256);M.HEAPU8.fill(0,p,p+256);assert(M._quantum_state_init(p,4)===0,'Moonlab init failed');return p;}
  function free(p){M._quantum_state_free(p);M._free(p);}
  function clone(p){const q=M._malloc(256);M.HEAPU8.fill(0,q,q+256);assert(M._quantum_state_clone(q,p)===0,'Moonlab clone failed');return q;}
  function gate(name,...a){M[name](...a);gates++;}
  function amps(p){const b=M.HEAPU32[(p+8)>>2]>>3;return Array.from({length:16},(_,i)=>[M.HEAPF64[b+2*i],M.HEAPF64[b+2*i+1]]);}
  function prepare(component=0){const p=state();
    if(preparation==='plus')for(let q=0;q<4;q++)gate('_gate_hadamard',p,q);
    if(preparation==='ghz'){gate('_gate_hadamard',p,0);for(let q=1;q<4;q++)gate('_gate_cnot',p,0,q);}
    if(preparation==='cross'){gate('_gate_hadamard',p,0);gate('_gate_hadamard',p,1);gate('_gate_cnot',p,0,2);gate('_gate_cnot',p,1,3);}
    if(preparation==='complex'){for(let q=0;q<4;q++){gate('_gate_ry',p,q,[.37,.81,1.23,1.87][q]);gate('_gate_rz',p,q,[-.43,.29,.61,-.71][q]);}gate('_gate_cnot',p,0,2);gate('_gate_cnot',p,1,3);gate('_gate_cnot',p,2,1);}
    if(preparation==='mixed')for(let q=0;q<4;q++)if(component&(1<<q))gate('_gate_pauli_x',p,q);
    return p;
  }
  function rotate(p,w){let t=-1;for(let q=0;q<4;q++){if(w[q]==='I')continue;if(t<0)t=q;if(w[q]==='Y')gate('_gate_s_dagger',p,q);if(w[q]==='X'||w[q]==='Y')gate('_gate_hadamard',p,q);}
    for(let q=0;q<4;q++)if(q!==t&&w[q]!=='I')gate('_gate_cnot',p,q,t);return t;}
  function undo(p,w,t){for(let q=3;q>=0;q--)if(q!==t&&w[q]!=='I')gate('_gate_cnot',p,q,t);for(let q=0;q<4;q++){if(w[q]==='X'||w[q]==='Y')gate('_gate_hadamard',p,q);if(w[q]==='Y')gate('_gate_s',p,q);}}
  function measure(p,w){const t=rotate(p,w),bit=M._measurement_single_qubit(p,t,random());measurements++;undo(p,w,t);return bit? -1:1;}
  function direct(v,w){let a=0,z=0,y=0;for(let q=0;q<4;q++){if('XY'.includes(w[q]))a|=1<<q;if('ZY'.includes(w[q]))z|=1<<q;if(w[q]==='Y')y++;}let re=0;const phase=[[1,0],[0,1],[-1,0],[0,-1]];
    for(let x=0;x<16;x++){let p=0,s=x&z;while(s){p^=s&1;s>>=1;}const [pr,pi]=phase[(y+2*p)%4],[ar,ai]=v[x],[br,bi]=v[x^a];re+=br*(pr*ar-pi*ai)+bi*(pr*ai+pi*ar);}return re;}
  const prepared=prepare();
  try{
    const v=amps(prepared);
    for(const w of observables){const q=clone(prepared);try{const t=rotate(q,w),value=M._measurement_expectation_z(q,t);maxError=Math.max(maxError,Math.abs(value-direct(v,w)));}finally{free(q);}}
    assert(maxError<1e-12,'Moonlab expectation oracle mismatch');
    const byContext=[];
    for(let ci=0;ci<contexts.length;ci++){const c=contexts[ci];let good=0;
      for(let s=0;s<shots;s++){const q=preparation==='mixed'?prepare(Math.floor(random()*16)):clone(prepared);let product=1;
        try{const order=[...c.indices];for(let j=order.length-1;j>0;j--){const k=Math.floor(random()*(j+1));[order[j],order[k]]=[order[k],order[j]];}for(const i of order)product*=measure(q,observables[i]);}
        finally{free(q);}trials++;if(product===c.sign){agree++;good++;}}
      byContext.push(good);onProgress((ci+1)/48);if(ci%4===0)await new Promise(resolve=>setTimeout(resolve,0));
    }
    assert(agree===trials,'At least one ideal context identity failed');
    return {status:'pass',engine:'Pinned Tsotchke Moonlab CPU/WASM; browser-native execution',preparation,shotsPerContext:shots,seed,sampler:'xorshift32 supplied to native Moonlab measurement',trials,agree,measurements,gates,maxExpectationOracleError:maxError,byContext,
      stateIndependenceScope:'Finite simulation is an implementation test; universal state independence follows from exact operator products, not sampling.'};
  }finally{free(prepared);}
}
