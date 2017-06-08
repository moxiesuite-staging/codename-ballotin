var Registry = artifacts.require("Registry");
var IndexedEnumerableSetLib = artifacts.require("vendor/IndexedEnumerableSetLib");

module.exports = function(deployer) {
  return deployer.then(function() {
    return deployer.link(IndexedEnumerableSetLib, Registry);
  }).then(function() {
    return deployer.deploy(Registry);
  });
};
