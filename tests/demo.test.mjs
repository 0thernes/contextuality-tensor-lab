import assert from 'node:assert/strict';
import {contexts,observables,evaluate,family,normalizedMargin,verifySigns,exhaustive} from '../docs/lab.mjs';
assert.equal(observables.length,18);
assert.equal(new Set(observables).size,18);
assert.equal(contexts.length,48);
assert.equal(contexts.filter(c=>c.indices.length===3).length,12);
assert.equal(contexts.filter(c=>c.indices.length===6).length,36);
assert(verifySigns().every(x=>x.valid));
const mutated=contexts.map(x=>({...x}));mutated[47].sign*=-1;
assert.deepEqual(verifySigns(mutated).filter(x=>!x.valid).map(x=>x.index),[47]);
assert.equal(evaluate(0).score,24);assert.equal(evaluate(0).violations,12);
for(let m=0;m<512;m++){const r=evaluate(m|(m<<9));assert.equal(r.score,(1+r.localScores[0])*(1+r.localScores[1])-1);}
const exact=exhaustive();
assert.equal(exact.assignments,262144);assert.equal(exact.best,24);
assert.equal(exact.minimumViolations,12);assert.equal(exact.minimizers,9216);
assert.equal(Object.values(exact.histogram).reduce((a,b)=>a+b),262144);
assert.equal(family('square',2).d,12n);assert.equal(family('pentagram',2).d,10n);
for(const kind of ['square','pentagram'])for(const k of [1,2,7,24,1000]){
  const f=family(kind,k);assert.equal(f.L-f.B,2n*f.d);assert(Number.isFinite(f.gap));
  assert(Math.abs(normalizedMargin(kind,k,0)-f.gap)<1e-12);
  assert(Math.abs(normalizedMargin(kind,k,f.threshold))<1e-12);
  assert(normalizedMargin(kind,k,f.threshold+0.001)<=0);
}
assert.throws(()=>family('square',0));assert.throws(()=>family('invalid',2));
console.log(JSON.stringify({status:'pass',exactPauliContexts:48,mutationRejected:true,exhaustive:exact}));
