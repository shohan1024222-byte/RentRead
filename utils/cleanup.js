const pool = require('../db');

async function expireOldRentals() {
  // deactivate any access_records whose expires_at <= NOW()
  const [result] = await pool.query('UPDATE access_records SET active=0 WHERE active=1 AND expires_at <= NOW()');
  return result;
}

module.exports = { expireOldRentals };
