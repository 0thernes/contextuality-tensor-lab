import {exhaustive} from './lab.mjs';
onmessage=()=>{try{const t=performance.now(),result=exhaustive(progress=>postMessage({progress}));postMessage({result,elapsed:performance.now()-t});}catch(error){postMessage({error:String(error)});}};
