// Real headless browser + WASM test. Install playwright into build/browser-test
// or provide PLAYWRIGHT_MODULE. BROWSER_EXECUTABLE may select an existing browser.
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const modulePath=process.env.PLAYWRIGHT_MODULE??path.join(root,'build/browser-test/node_modules/playwright/index.mjs');
const {chromium}=await import(pathToFileURL(modulePath));
const executablePath=process.env.BROWSER_EXECUTABLE??(process.platform==='win32'?'C:/Program Files/Google/Chrome/Application/chrome.exe':undefined);
const docroot=path.join(root,'docs');
const server=createServer(async(req,res)=>{try{let pathname=decodeURIComponent(new URL(req.url,'http://localhost').pathname);if(pathname==='/')pathname='/index.html';
  const file=path.resolve(docroot,'.'+pathname);if(!file.startsWith(docroot+path.sep))throw Error('path');
  const mime={'.html':'text/html','.css':'text/css','.js':'text/javascript','.mjs':'text/javascript','.wasm':'application/wasm','.json':'application/json'}[path.extname(file)]??'application/octet-stream';
  const data=await fs.readFile(file);res.writeHead(200,{'Content-Type':mime});res.end(data);
}catch{res.writeHead(404);res.end('Not found');}});
await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
const browser=await chromium.launch({headless:true,executablePath});
const errors=[],checks=[];
try{
  const page=await browser.newPage({viewport:{width:1440,height:1050},acceptDownloads:true});
  page.on('pageerror',e=>errors.push(String(e)));
  await page.goto(`http://127.0.0.1:${server.address().port}/`,{waitUntil:'networkidle'});
  assert.equal(await page.locator('.observable').count(),18);assert.equal(await page.locator('.context-tile').count(),48);
  assert.equal(await page.locator('#score').textContent(),'24');checks.push('initial exact certificate');
  await page.locator('.observable').first().click();assert.equal(await page.locator('#score').textContent(),'4');assert.equal(await page.locator('#violations').textContent(),'22 / 48');
  await page.locator('#reset').click();assert.equal(await page.locator('#score').textContent(),'24');checks.push('interactive assignment flip and reset');
  await page.locator('#mutate').click();assert.match(await page.locator('#certificateStatus').textContent(),/Mutation rejected.*context 48/);checks.push('exact sign negative control');
  await page.locator('#enumerate').click();await page.waitForFunction(()=>document.getElementById('certificateStatus').textContent.startsWith('Verified locally:'),{timeout:30000});checks.push('worker direct exhaustive enumeration');
  const simulations=[];
  await page.selectOption('#shots','8');
  for(const preparation of ['ghz','cross','plus','complex','mixed']){
    await page.selectOption('#preparation',preparation);await page.locator('#runMoonlab').click();
    await page.waitForFunction(()=>!document.getElementById('runMoonlab').disabled,{timeout:60000});
    const status=await page.locator('#simStatus').textContent();assert.match(status,/^PASS/);
    assert.equal(await page.locator('#simAgreement').textContent(),'384 / 384');simulations.push({preparation,status});
  }checks.push('native browser Moonlab: five preparations, 1920 context shots');
  await page.selectOption('#family','pentagram');assert.equal(await page.locator('#largeDegree').textContent(),'10');
  await page.locator('#copies').evaluate(x=>{x.value='24';x.dispatchEvent(new Event('input',{bubbles:true}));});
  await page.locator('#noise').evaluate(x=>{x.value='0.2';x.dispatchEvent(new Event('input',{bubbles:true}));});
  assert.match(await page.locator('#noiseExplanation').textContent(),/does not restore/);assert.equal(await page.locator('#noisePlot path').count(),2);checks.push('BigInt pentagram counts and high-noise model');
  const downloadEvent=page.waitForEvent('download');await page.locator('#download').click();const download=await downloadEvent;
  const cert=JSON.parse(await fs.readFile(await download.path(),'utf8'));assert.equal(cert.exhaustiveEnumeration.minimumViolations,12);assert.equal(cert.liveMoonlab.status,'pass');checks.push('downloaded live certificate');
  await page.selectOption('#family','square');await page.locator('#copies').evaluate(x=>{x.value='2';x.dispatchEvent(new Event('input',{bubbles:true}));});await page.locator('#noise').evaluate(x=>{x.value='0.02';x.dispatchEvent(new Event('input',{bubbles:true}));});
  await page.evaluate(()=>scrollTo(0,0));await page.screenshot({path:path.join(root,'build/browser-desktop.png'),fullPage:true});
  await page.setViewportSize({width:390,height:844});await page.evaluate(()=>scrollTo(0,0));
  await page.screenshot({path:path.join(root,'build/browser-mobile.png'),fullPage:true});checks.push('390px mobile layout without horizontal overflow');
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),
    'Mobile horizontal overflow: '+JSON.stringify(await page.evaluate(()=>Array.from(document.querySelectorAll('*')).filter(e=>e.getBoundingClientRect().right>innerWidth+1).map(e=>({tag:e.tagName,id:e.id,class:e.className,right:e.getBoundingClientRect().right})).slice(0,20))));
  assert.deepEqual(errors,[]);
  const report={status:'pass',checks,simulations,pageErrors:errors,browser:await browser.version(),scope:'Real local Chrome headless browser, live WASM and module worker; not a physical quantum experiment'};
  await fs.writeFile(path.join(root,'results/stack_browser.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
}finally{await browser.close();server.close();}
