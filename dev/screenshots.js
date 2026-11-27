// Captures des écrans de connexion (Playwright). Usage : node dev/screenshots.js
// OUT=dossier/ CS=light|dark pour changer la sortie ou le thème du navigateur.
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch();
  const out = process.env.OUT || 'captures/';
  require('fs').mkdirSync(out, { recursive: true });
  for (const [name, w, h] of [['desk',1440,900],['mob',390,844]]) {
    const ctx = await b.newContext({ locale: 'fr-FR', viewport: {width:w,height:h}, colorScheme: process.env.CS||'dark' });
    const p = await ctx.newPage();
    p.on('pageerror', e => console.log('ERR', e.message));
    await p.goto('http://localhost:9000/if/flow/default-authentication-flow/?next=%2F', {waitUntil:'networkidle'});
    await p.waitForTimeout(1500);
    await p.screenshot({ path: out + name + '-1.png' });
    await p.locator('input[name=uidField]').fill('akadmin');
    await p.keyboard.press('Enter');
    await p.waitForTimeout(2000);
    await p.screenshot({ path: out + name + '-2.png' });
    if (name === 'desk') {
      await p.locator('input[name=password]').fill('wrong'); await p.keyboard.press('Enter'); await p.waitForTimeout(1800);
      await p.screenshot({ path: out + name + '-2err.png' });
    }
    await ctx.close();
  }
  await b.close();
})();
