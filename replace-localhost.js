/**
 * replace-localhost.js
 * 
 * Replaces localhost / 127.0.0.1 in models.json baseUrl fields
 * with the Docker host IP so containers can reach the host machine.
 * 
 * Targets: providers.*.baseUrl
 * 
 * Usage: node replace-localhost.js
 * 
 * Docker-in-Docker host detection order:
 *   1. DOCKER_HOST_IP env var (explicit override)
 *   2. docker0 bridge gateway (common on Linux)
 *   3. host.docker.internal resolution fallback
 */

const fs = require('fs');
const path = require('path');

// --- Helpers ---

/**
 * Try to resolve the Docker host IP from the docker0 bridge gateway.
 * Works on Linux hosts where Docker creates a 172.17.0.1 bridge.
 */
function getDockerHostIP() {
  // 1. Explicit env var override
  if (process.env.DOCKER_HOST_IP) {
    return process.env.DOCKER_HOST_IP;
  }

  // 2. Try reading /proc/net/route for the default gateway via docker0
  try {
    const route = fs.readFileSync('/proc/net/route', 'utf8');
    const lines = route.trim().split('\n');
    for (const line of lines.slice(1)) {
      const parts = line.split(/\s+/);
      const iface = parts[0];
      if (iface === 'docker0' || iface === 'eth0') {
        const gatewayHex = parts[1]; // destination
        const gwIp = Buffer.from(gatewayHex, 'hex').reverse().join('.');
        if (gwIp && gwIp !== '0.0.0.0') {
          return gwIp;
        }
      }
    }
  } catch (_) { /* ignore */ }

  // 3. Try common Docker bridge subnets
  const commonIPs = [
    '172.17.0.1',   // default bridge
    '172.18.0.1',
    '172.19.0.1',
    '192.168.65.1', // Docker Desktop (macOS/Windows)
  ];
  return commonIPs[0];
}

/**
 * Replace localhost in a baseUrl string with hostIP.
 * e.g. http://localhost:1234/v1 → http://172.17.0.1:1234/v1
 */
function fixBaseUrl(baseUrl, hostIP) {
  if (typeof baseUrl !== 'string') return baseUrl;
  const trimmed = baseUrl.trim().toLowerCase();
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) return baseUrl;

  const url = new URL(baseUrl);
  if (url.hostname === 'localhost' || url.hostname === '127.0.0.1' || url.hostname === '[::1]') {
    const port = url.port ? `:${url.port}` : '';
    return `${url.protocol}//${hostIP}${port}${url.pathname}${url.search}`;
  }
  return baseUrl;
}

// --- Main ---

function main() {
  const filePath = '/home/piuser/.pi/agent/models.json';

  if (!filePath) {
    console.error('Usage: node replace-localhost.js <models.json path>');
    process.exit(1);
  }

  if (!fs.existsSync(filePath)) {
    console.error(`File not found: ${filePath}`);
    process.exit(1);
  }

  console.log(`Reading: ${filePath}`);
  const raw = fs.readFileSync(filePath, 'utf8');

  let data;
  try {
    data = JSON.parse(raw);
  } catch (e) {
    console.error(`Failed to parse JSON: ${e.message}`);
    process.exit(1);
  }

  const hostIP = `host.docker.internal`; //getDockerHostIP();
  console.log(`Docker host IP: ${hostIP}`);

  if (!data.providers || typeof data.providers !== 'object') {
    console.error('No providers found in models.json');
    process.exit(1);
  }

  let updated = 0;
  for (const [name, provider] of Object.entries(data.providers)) {
    if (provider.baseUrl) {
      const before = provider.baseUrl;
      provider.baseUrl = fixBaseUrl(before, hostIP);
      if (provider.baseUrl !== before) {
        console.log(`  ${name}: ${before} → ${provider.baseUrl}`);
        updated++;
      }
    }
  }

  if (updated === 0) {
    console.log('No localhost addresses found. No changes needed.');
  }

  const output = JSON.stringify(data, null, 2);
  fs.writeFileSync(filePath, output + '\n', 'utf8');

  console.log(`Updated: ${filePath}`);
}

main();

module.exports = { fixBaseUrl, getDockerHostIP, main };
