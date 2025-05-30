import https from 'https';
import fetch from 'node-fetch';

const agent = new https.Agent({  
  rejectUnauthorized: false
});

export const fetchWithSSL = (url, options = {}) => {
  console.log(`Realizando petición a: ${url}`);
  return fetch(url, {
    ...options,
    agent: url.startsWith('https') ? agent : undefined,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...(options.headers || {})
    }
  });
};



