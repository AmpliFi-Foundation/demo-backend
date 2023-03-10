// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";

import { UD60x18, unwrap } from "@prb-math/UD60x18.sol";
import { MathHelper } from "src/utils/MathHelper.sol";
import { UniswapV3Math } from "src/utils/UniswapV3Math.sol";

contract BaseScript0 is Script {
    address public uniswapFactory = vm.parseAddress("0x1F98431c8aD98523631AE4a59f267346ea31F984");
    address public uniswapNPM = vm.parseAddress("0xC36442b4a4522E871399CD717aBDD847Ab11FE88");
    address public uniswapSwapRouter = vm.parseAddress("0xE592427A0AEce92De3Edee1F18E0157C05861564");

    address public USDC = vm.parseAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48");
    address public DAI = vm.parseAddress("0x6B175474E89094C44Da98b954EedeAC495271d0F");
    address public WETH9 = vm.parseAddress("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");

    // address public USDC = vm.parseAddress("0x07865c6E87B9F70255377e024ace6630C1Eaa37F"); // Goerli Testnet
    // address public DAI = vm.parseAddress("0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844");
    // address public WETH9 = vm.parseAddress("0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6");

    address public anvilAddr0 = vm.parseAddress("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    address public anvilAddr1 = vm.parseAddress("0x70997970C51812dc3A010C7d01b50e0d17dc79C8");
    address public anvilAddr2 = vm.parseAddress("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC");
    address public anvilAddr3 = vm.parseAddress("0x90F79bf6EB2c4f870365E785982E1f101E93b906");
    address public anvilAddr4 = vm.parseAddress("0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65");
    address public anvilAddr5 = vm.parseAddress("0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc");
    address public anvilAddr6 = vm.parseAddress("0x976EA74026E726554dB657fA54763abd0C3a0aa9");
    address public anvilAddr7 = vm.parseAddress("0x14dC79964da2C08b23698B3D3cc7Ca32193d9955");
    address public anvilAddr8 = vm.parseAddress("0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f");
    address public anvilAddr9 = vm.parseAddress("0xa0Ee7A142d267C1f36714E4a8F75612F20a79720");

    uint public anvilPk0 = vm.parseUint("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
    uint public anvilPk1 = vm.parseUint("0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d");
    uint public anvilPk2 = vm.parseUint("0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a");
    uint public anvilPk3 = vm.parseUint("0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6");
    uint public anvilPk4 = vm.parseUint("0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a");
    uint public anvilPk5 = vm.parseUint("0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba");
    uint public anvilPk6 = vm.parseUint("0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e");
    uint public anvilPk7 = vm.parseUint("0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356");
    uint public anvilPk8 = vm.parseUint("0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97");
    uint public anvilPk9 = vm.parseUint("0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6");

    modifier broadcast(uint privateKey) {
        vm.startBroadcast(privateKey);
        _;
        vm.stopBroadcast();
    }

    function toFixPoint96(UD60x18 from) internal pure returns (uint160) {
        return uint160(MathHelper.mulDivRoundUp(unwrap(from), UniswapV3Math.Q96, 1e18));
    }

    function fromFixPoint96(uint160 from) internal pure returns (UD60x18) {
        return UD60x18.wrap(MathHelper.mulDivRoundUp(from, 1e18, UniswapV3Math.Q96));
    }
}
