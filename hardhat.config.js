require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html

const accounts = {
  mnemonic: process.env.MNEMONIC || "test test test test test test test test test test test junk",
  // initialIndex: 18
  // accountsBalance: "990000000000000000000",
}

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  spdxLicenseIdentifier: {
    overwrite: false,
    runOnCompile: true,
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey:"6IQTZTMD392X2U2SYZBABWDS8KB6D8UD4T"
  },
  defaultNetwork: "local",
  networks: {
    local: {
      url: `http://localhost:8545`,
      accounts,
      attachs:{
           fee: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
           usdt:"0xD6b040736e948621c5b6E0a494473c47a6113eA8",
           bch:"0xeF31027350Be2c7439C1b0BE022d49421488b72C",
           hbtc:"0xa0945a7aC164287B4e6B8f234337820807074a29",
           heth:"0x9771321265cAD7049903EaF4a574Eab51fD97378",
           hltc:"0x8E02433C31B51ABe3Ac65908d59eF82ddB52714F",
           wbnb :"0x7B4f352Cd40114f12e82fC675b5BA8C7582FC513",
           hdot:"0x426dcD4fa088D7b33797Da0002bF36a669B398D5",
           bwtoken:"0x82EdA215Fa92B45a3a76837C65Ab862b6C7564a8",
           uniswap:{
             factory:"0x359570B3a0437805D0a71457D61AD26a28cAC9A2",
             router: "0x162700d1613DfEC978032A909DE02643bC55df1A",
           },
           bxh : "0xcE0066b1008237625dDDBE4a751827de037E53D2",
           repurchase:"0x87006e75a5B6bE9D1bbF61AC8Cd84f05D9140589",
           references:"0x8fC8CFB7f7362E44E472c690A6e025B80E406458",
           airdroppool:"0x70eE76691Bdd9696552AF8d4fd634b3cF79DD529",
           feecollector:"0x8B190573374637f144AC8D37375d97fd84cBD3a0",
           oracle:"0x67aD6EA566BA6B0fC52e97Bc25CE46120fdAc04c",
           tokenlock:"0x114e375B6FCC6d6fCb68c7A1d407E652C54F25FB",
           bxhpool: "0x8D81A3DCd17030cD5F23Ac7370e4Efb10D2b3cA4",
           swapmining: "0xcD0048A5628B37B8f743cC2FeA18817A29e97270",
           paramfeecalctor: "0xcD0048A5628B37B8f743cC2FeA18817A29e97270",

      }
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      gasPrice: 120 * 1000000000,
      chainId: 1,
    },
    heco:{
      url: `https://bsc-dataseed.binance.org/`,
      accounts,
      gasPrice: 20*1000000000,
      chainId: 128,
      loggingEnabled: true,
      blockGasLimit:0x280de80,
      attachs:{
          fee: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
           usdt:"0x41dBB528b5662caD3b8183754C0517b409E00Fa8",
           husd:"0x60aC4593ecea0B22216218c4D0f27533ebB01CB6",
           hbtc:"0xa0945a7aC164287B4e6B8f234337820807074a29",
           heth:"0x9771321265cAD7049903EaF4a574Eab51fD97378",
           hltc:"0x8E02433C31B51ABe3Ac65908d59eF82ddB52714F",
           wbnb :"0x7f3fF452D3da0EAD3ce227eB4A6c84E896685C3C",
           hdot:"0x426dcD4fa088D7b33797Da0002bF36a669B398D5",
           uniswap:{
             factory:"0x607c2d79E406a5DC2D1E01b6820dd5a72FbA58C7",
             router: "0xfC3035f60A3d862E0753eA3D2Eec7679227E8B37",
           },
           bxh : "0xefAB0Beb0A557E452b398035eA964948c750b2Fd",
           feecollector: "0xaca81583840B1bf2dDF6CDe824ada250C1936B4D",
           bxhpool: "0x8a5592b0E95767886642269AEb0B7A80dAa22c8f",
           oracle: "0x12754d8FCCb302097A8f67Fa7dE8981Ef5FC3106",
           tokenlock: "0x12754d8FCCb302097A8f67Fa7dE8981Ef5FC3106",
           swapmining: "0xb2cAa6f80efA72b236fd6393CA1229754Aa24f63",
        }
    },
    bsclocal:{
      url: `http://114.115.173.246:38545`,
      accounts,
      gasPrice: 0x3b9aca00,
      chainId: 1000,
      attachs:{
           fee: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
           usdt:"0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
           husd:"0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9",
           hbtc:"0x5FC8d32690cc91D4c39d9d3abcBD16989F875707",
           heth:"0x0165878A594ca255338adfa4d48449f69242Eb8F",
           hltc:"0xa513E6E4b8f2a923D98304ec87F64353C4D5C853",
           wbnb :"0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6",
           hdot:"0x8A791620dd6260079BF849Dc5567aDC3F2FdC318",
           uniswap:{
             factory:"0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e",
             router: "0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0",
           },
           bxh : "0xefAB0Beb0A557E452b398035eA964948c750b2Fd",
           feecollector: "0xaca81583840B1bf2dDF6CDe824ada250C1936B4D",
           bxhpool: "0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82",
          
           oracle: "0x0B306BF915C4d645ff596e518fAf3F9669b97016",
           tokenlock: "0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1",
           swapmining: "0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE",
      },
    },
  }
};

