// Pure, independently executable arithmetic for the live browser.
export const words=['XI','IX','XX','IZ','ZI','ZZ','XZ','ZX','YY'];
export const local=[[0,1,2,1],[3,4,5,1],[6,7,8,1],[0,3,6,1],[1,4,7,1],[2,5,8,-1]];
export const observables=[...words.map(s=>s+'II'),...words.map(s=>'II'+s)];
export const contexts=[];
for(let a=0;a<7;a++)for(let b=0;b<7;b++)if(a||b){
  const indices=[];let sign=1;
  if(a){indices.push(...local[a-1].slice(0,3));sign*=local[a-1][3];}
  if(b){indices.push(...local[b-1].slice(0,3).map(x=>x+9));sign*=local[b-1][3];}
  contexts.push({indices,sign,choices:[a,b],mask:indices.reduce((s,x)=>s|(1<<x),0)});
}
export function parity(x){x^=x>>>16;x^=x>>>8;x^=x>>>4;return(0x6996>>>(x&15))&1;}
export function evaluate(mask){
  const values=contexts.map(c=>c.sign*(parity(mask&c.mask)?-1:1));
  const localScores=[0,1].map(b=>local.reduce((s,c)=>s+c[3]*(parity((mask>>>(b*9))&c.slice(0,3).reduce((v,x)=>v|(1<<x),0))?-1:1),0));
  const score=values.reduce((a,b)=>a+b,0);
  return {mask,values,localScores,score,violations:(48-score)/2};
}
export function family(kind,k){
  if(!Number.isInteger(k)||k<1||k>1000)throw Error('k must be an integer from 1 to 1000');
  const square=kind==='square';if(!square&&kind!=='pentagram')throw Error('unknown family');
  const m=square?6:5,b=square?4:3,r=square?3:4;
  const n=BigInt(k),L=BigInt(m+1)**n-1n,B=BigInt(b+1)**n-1n,d=(L-B)/2n;
  return {kind,k,m,b,r,L,B,d,qubits:(square?2:3)*k,observables:(square?9:10)*k,
    gap:(1-((b+1)/(m+1))**k)/(1-(m+1)**(-k)),threshold:(1-(b/m)**(1/r))/2};
}
export function normalizedMargin(kind,k,p){const f=family(kind,k),t=(1-2*p)**f.r;
  // Ratios avoid overflow for arbitrarily large BigInt counts.
  const scale=(f.m+1)**(-k);
  return ((((1+f.m*t)/(f.m+1))**k)-(((1+f.b)/(f.m+1))**k))/(1-scale);
}
const mult={II:[0,'I'],IX:[0,'X'],IY:[0,'Y'],IZ:[0,'Z'],XI:[0,'X'],XX:[0,'I'],XY:[1,'Z'],XZ:[3,'Y'],YI:[0,'Y'],YX:[3,'Z'],YY:[0,'I'],YZ:[1,'X'],ZI:[0,'Z'],ZX:[1,'Y'],ZY:[3,'X'],ZZ:[0,'I']};
export function product(labels){let phase=0,out='IIII';for(const label of labels){let next='';for(let q=0;q<4;q++){const [p,w]=mult[out[q]+label[q]];phase+=p;next+=w;}out=next;}return{phase:phase%4,word:out};}
export function verifySigns(list=contexts){return list.map((c,index)=>{const actual=product(c.indices.map(i=>observables[i]));
  const commute=c.indices.every(a=>c.indices.every(b=>JSON.stringify(product([observables[a],observables[b]]))===JSON.stringify(product([observables[b],observables[a]]))));
  return {index,valid:commute&&actual.word==='IIII'&&actual.phase===(c.sign===1?0:2),actual,claimedSign:c.sign};});}
export function exhaustive(progress=()=>{}){
  let best=-99,minimizers=0;const histogram={};
  for(let mask=0;mask<262144;mask++){
    let score=0;for(const c of contexts)score+=c.sign*(parity(mask&c.mask)?-1:1);
    if(score>best){best=score;minimizers=1;}else if(score===best)minimizers++;
    histogram[score]=(histogram[score]??0)+1;
    if(mask%16384===0)progress(mask/262144);
  }
  return {assignments:262144,contexts:48,best,minimumViolations:(48-best)/2,minimizers,histogram,method:'Direct evaluation of all 48 signed products for every 18-bit assignment'};
}
