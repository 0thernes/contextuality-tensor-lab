import {words,contexts,observables,evaluate,family,normalizedMargin,verifySigns} from './lab.mjs';
import {simulate} from './moonlab_live.mjs';
const $=id=>document.getElementById(id);let assignment=0,enumeration=null,simulation=null;
const number=x=>x.toLocaleString('en-US');
for(let b=0;b<2;b++)for(let i=0;i<9;i++){
  const button=document.createElement('button');button.className='observable';button.dataset.index=b*9+i;
  button.innerHTML='<span class="word">'+words[i]+'</span><span class="sign">+1</span>';
  button.onclick=()=>{assignment^=1<<(b*9+i);renderAssignment();};$(b?'squareB':'squareA').append(button);
}
for(let i=0;i<48;i++){const tile=document.createElement('span');tile.className='context-tile';tile.dataset.index=i;tile.tabIndex=0;$('contextGrid').append(tile);}
function renderAssignment(){const result=evaluate(assignment);
  document.querySelectorAll('.observable').forEach(button=>{const i=Number(button.dataset.index),negative=Boolean(assignment&(1<<i));button.classList.toggle('negative',negative);button.querySelector('.sign').textContent=negative?'−1':'+1';button.setAttribute('aria-label',`Block ${i<9?'A':'B'} ${words[i%9]} assigned ${negative?'minus':'plus'} one; click to flip`);button.setAttribute('aria-pressed',String(negative));});
  document.querySelectorAll('.context-tile').forEach((tile,i)=>{const good=result.values[i]===1,c=contexts[i];tile.classList.toggle('fail',!good);tile.textContent=good?'+':'−';const desc=`Context ${i+1}: ${c.indices.map(j=>observables[j]).join(' · ')}. Required product ${c.sign}. ${good?'Satisfied':'Violated'}.`;tile.title=desc;tile.setAttribute('aria-label',desc);});
  $('score').textContent=result.score;$('violations').textContent=`${result.violations} / 48`;
  $('factorization').textContent=`(1 + ${result.localScores[0]}) × (1 + ${result.localScores[1]}) − 1 = ${result.score}`;
}
$('reset').onclick=()=>{assignment=0;renderAssignment();};renderAssignment();
const signChecks=verifySigns();if(signChecks.some(c=>!c.valid))throw Error('Built-in exact Pauli signs failed');
$('mutate').onclick=()=>{const changed=contexts.map(c=>({...c}));changed[47].sign*=-1;const failed=verifySigns(changed).filter(c=>!c.valid);$('certificateStatus').className='success';$('certificateStatus').textContent=failed.length===1&&failed[0].index===47?'Mutation rejected: context 48 multiplies to +I, but the injected certificate claims −I. Exact Pauli multiplication detected the error.':'Unexpected mutation result — inspect the certificate.';};
$('enumerate').onclick=()=>{const button=$('enumerate');button.disabled=true;$('enumProgress').hidden=false;$('enumProgress').value=0;$('certificateStatus').className='';$('certificateStatus').textContent='Evaluating every assignment in a background worker…';const worker=new Worker(new URL('./worker.mjs',import.meta.url),{type:'module'});
  const fail=message=>{button.disabled=false;$('enumProgress').hidden=true;$('certificateStatus').className='error';$('certificateStatus').textContent=message;worker.terminate();};
  worker.onerror=event=>fail('Enumeration failed: '+event.message);
  worker.onmessage=({data})=>{if(data.error)return fail(data.error);if(data.progress!==undefined)$('enumProgress').value=data.progress;
    if(data.result){enumeration=data.result;button.disabled=false;$('enumProgress').value=1;const valid=enumeration.best===24&&enumeration.minimumViolations===12&&enumeration.minimizers===9216;
      $('certificateStatus').className=valid?'success':'error';$('certificateStatus').textContent=`${valid?'Verified':'FAILED'} locally: ${number(enumeration.assignments)} assignments × 48 explicit signed products. Maximum score ${enumeration.best}; minimum violations ${enumeration.minimumViolations}; ${number(enumeration.minimizers)} optimal assignments. ${(data.elapsed/1000).toFixed(2)} s.`;worker.terminate();}};
  worker.postMessage({start:true});
};
$('download').onclick=()=>{const data={format:'contextuality-tensor-browser-certificate-v1',generatedAt:new Date().toISOString(),observables,contexts,assignment:evaluate(assignment),exactPauliProducts:signChecks,exhaustiveEnumeration:enumeration,liveMoonlab:simulation,
  scope:'Browser-computed finite evidence. No open conjecture resolution, quantum hardware, peer review or priority claim.'};const url=URL.createObjectURL(new Blob([JSON.stringify(data,null,2)+'\n'],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download='contextuality-certificate.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);};
$('runMoonlab').onclick=async()=>{const button=$('runMoonlab');button.disabled=true;$('simStatus').className='';$('simStatus').textContent='Loading Moonlab and preparing the state…';const start=performance.now();
  try{simulation=await simulate({preparation:$('preparation').value,shots:Number($('shots').value),seed:Number($('simSeed').value),onProgress:p=>{$('simStatus').textContent=`Native Moonlab measurements: ${Math.round(p*100)}% of contexts complete…`;}});
    $('simAgreement').textContent=`${number(simulation.agree)} / ${number(simulation.trials)}`;$('simMeasurements').textContent=number(simulation.measurements);$('simError').textContent=simulation.maxExpectationOracleError.toExponential(1);$('simStatus').className='success';$('simStatus').textContent=`PASS · All 48 context identities held in this run. ${number(simulation.gates)} native gate calls, ${((performance.now()-start)/1000).toFixed(2)} s. This live result is included in the downloadable certificate.`;
  }catch(error){$('simStatus').className='error';$('simStatus').textContent='Simulation failed: '+error.message;}finally{button.disabled=false;}};
function renderScaling(){const kind=$('family').value,k=Number($('copies').value),p=Number($('noise').value),f=family(kind,k);$('copiesLabel').textContent=k;$('noiseLabel').textContent=p.toFixed(3);
  $('largeContexts').textContent=number(f.L);$('largeBound').textContent=number(f.B);$('largeDegree').textContent=number(f.d);$('largeGap').textContent=f.gap.toFixed(6);$('noiseThreshold').textContent=`${f.threshold.toFixed(6)} (${(f.threshold*100).toFixed(3)}%) · independent of k`;
  const margin=normalizedMargin(kind,k,p);$('noiseExplanation').textContent=`At k = ${k}, the ${p===0?'ideal':'noisy'} normalized margin is ${margin.toFixed(6)}. ${p===0?'The ideal gap approaches 1 as more blocks are added.':p<f.threshold?'The inequality remains violated, but for any fixed positive p this normalized noisy margin approaches 0 as k grows.':'This readout error is at or above the threshold; adding copies does not restore the violation.'}`;
  const W=620,H=300,left=48,right=18,top=24,bottom=40,min=-.55,max=1.02,x=j=>left+(j-1)/23*(W-left-right),y=v=>top+(max-v)/(max-min)*(H-top-bottom);
  let markup='';for(const t of [-.5,-.25,0,.25,.5,.75,1])markup+=`<line x1="${left}" x2="${W-right}" y1="${y(t)}" y2="${y(t)}" stroke="${t===0?'#52616d':'#263441'}" stroke-dasharray="${t===0?'0':'3 5'}"/><text x="${left-9}" y="${y(t)+4}" text-anchor="end" fill="#91a5b5" font-size="10">${t.toFixed(2)}</text>`;
  for(const j of [1,4,8,12,16,20,24])markup+=`<text x="${x(j)}" y="${H-18}" text-anchor="middle" fill="#91a5b5" font-size="11">${j}</text>`;
  for(const [q,color] of [[0,'#73e2cd'],[p,'#88baff']]){const d=Array.from({length:24},(_,i)=>`${i?'L':'M'}${x(i+1).toFixed(2)},${y(normalizedMargin(kind,i+1,q)).toFixed(2)}`).join(' ');markup+=`<path d="${d}" fill="none" stroke="${color}" stroke-width="2.5"/>`;}
  markup+=`<line x1="${x(k)}" x2="${x(k)}" y1="${top}" y2="${H-bottom}" stroke="#91a5b5" stroke-dasharray="3 5"/><circle cx="${x(k)}" cy="${y(margin)}" r="4" fill="#88baff"/><text x="${W-right}" y="${H-1}" text-anchor="end" fill="#91a5b5" font-size="10">blocks k</text>`;$('noisePlot').innerHTML=markup;
}
for(const id of ['family','copies','noise'])$(id).addEventListener('input',renderScaling);renderScaling();
