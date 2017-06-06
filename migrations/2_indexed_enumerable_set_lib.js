var IndexedEnumerableSetLib = artifacts.require("vendor/IndexedEnumerableSetLib");

module.exports = function(deployer) {
  return deployer.then(function() {
    return deployer.deploy(IndexedEnumerableSetLib);
  });
};
