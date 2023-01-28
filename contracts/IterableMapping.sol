// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) isInvest;
        mapping(address => bool) isClaimed;
    }

    function get(Map storage map, address key) internal view returns (uint256 value, bool isInvest, bool isClaimed) {
        value=map.values[key];
        isInvest=map.isInvest[key];
        isClaimed=map.isClaimed[key];
    }

    function getIndexOfKey(Map storage map, address key)
        internal
        view
        returns (int256)
    {
        if (!map.isInvest[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        internal
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function getKeys(Map storage map) internal view returns (address[] memory) {
        return map.keys;
    }

    function invest(
        Map storage map,
        address key,
        uint256 val
    ) internal {
        if (map.isInvest[key]) {
            map.values[key] += val;
        } else {
            map.isInvest[key] = true;
            map.values[key] += val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function claim(
        Map storage map,
        address key
    ) internal {
        require(map.isInvest[key], "no invest");
        require(!map.isClaimed[key], "already claimed");
        require(map.values[key]>0, "value>0");
        map.isClaimed[key] = true;
    }

    function remove(Map storage map, address key) internal {
        if (!map.isInvest[key]) {
            return;
        }

        delete map.isInvest[key];
        delete map.values[key];
        delete map.isClaimed[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
