const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;
const root = __dirname;

app.use(express.static(root, {
  maxAge: '1h',
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('sw.js')) {
      res.setHeader('Cache-Control', 'no-cache');
    }
  }
}));

app.get('/health', (_req, res) => {
  res.status(200).send('ok');
});

app.get('*', (_req, res) => {
  res.sendFile(path.join(root, 'index.html'));
});

app.listen(port, () => {
  console.log(`Label Maskine listening on port ${port}`);
});
