var BoxDB = artifacts.require("BoxDB");
var IndexedEnumerableSetLib = artifacts.require("vendor/IndexedEnumerableSetLib");

module.exports = function(deployer) {
  return deployer.then(function() {
    return deployer.link(IndexedEnumerableSetLib, BoxDB);
  });
};
