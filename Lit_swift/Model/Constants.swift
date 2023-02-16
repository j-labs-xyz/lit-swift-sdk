//
//  Constants.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/14.
//
 
import Foundation

var ALL_LIT_CHAINS: LITChain<LITEVMChain> = {
    var chains: LITChain<LITEVMChain> = [:]
    chains.merge(LIT_CHAINS) { _, new in new }
    chains.merge(LIT_SVM_CHAINS) { _, new in new }
    chains.merge(LIT_COSMOS_CHAINS) { _, new in new }
    return chains
}()


public let LIT_CHAINS: LITChain<LITEVMChain> = [
    .ethereum : LITEVMChain(contractAddress: "0xA54F7579fFb3F98bd8649fF02813F575f9b3d353",
                            chainId: 1,
                            type: "ERC1155",
                            name: "Ethereum",
                            symbol: "ETH",
                            decimals: 18,
                            rpcUrls: ["https://eth-mainnet.alchemyapi.io/v2/EuGnkVlzVoEkzdg0lpCarhm8YHOxWVxE"],
                            blockExplorerUrls: ["https://etherscan.io"],
                            vmType: .EVM),
    .polygon : LITEVMChain(contractAddress: "0x7C7757a9675f06F3BE4618bB68732c4aB25D2e88",
                           chainId: 137,
                           type: "ERC1155",
                           name: "Polygon",
                           symbol: "MATIC",
                           decimals: 18,
                           rpcUrls: ["https://polygon-rpc.com"],
                           blockExplorerUrls: ["https://explorer.matic.network"],
                           vmType: .EVM),
    .fantom : LITEVMChain(contractAddress: "0x5bD3Fe8Ab542f0AaBF7552FAAf376Fd8Aa9b3869",
                           chainId: 250,
                           type: "ERC1155",
                           name: "Fantom",
                           symbol: "FTM",
                           decimals: 18,
                           rpcUrls: ["https://rpcapi.fantom.network"],
                           blockExplorerUrls: ["https://ftmscan.com"],
                           vmType: .EVM),
    .xdai : LITEVMChain(contractAddress: "0xDFc2Fd83dFfD0Dafb216F412aB3B18f2777406aF",
                           chainId: 100,
                           type: "ERC1155",
                           name: "xDai",
                           symbol: "xDai",
                           decimals: 18,
                           rpcUrls: ["https://rpc.gnosischain.com"],
                           blockExplorerUrls: ["https://blockscout.com/xdai/mainnet"],
                           vmType: .EVM),
    .bsc : LITEVMChain(contractAddress: "0xc716950e5DEae248160109F562e1C9bF8E0CA25B",
                           chainId: 56,
                           type: "ERC1155",
                           name: "Binance Smart Chain",
                           symbol: "BNB",
                           decimals: 18,
                           rpcUrls: ["https://bsc-dataseed.binance.org/"],
                           blockExplorerUrls: ["https://bscscan.com/"],
                           vmType: .EVM),
    .arbitrum : LITEVMChain(contractAddress: "0xc716950e5DEae248160109F562e1C9bF8E0CA25B",
                               chainId: 42161,
                               type: "ERC1155",
                               name: "Arbitrum",
                               symbol: "AETH",
                               decimals: 18,
                               rpcUrls: ["https://arb1.arbitrum.io/rpc"],
                               blockExplorerUrls: ["https://arbiscan.io/"],
                               vmType: .EVM),
    .avalanche : LITEVMChain(contractAddress: "0xBB118507E802D17ECDD4343797066dDc13Cde7C6",
                               chainId: 43114,
                               type: "ERC1155",
                               name: "Avalanche",
                               symbol: "AVAX",
                               decimals: 18,
                               rpcUrls: ["https://api.avax.network/ext/bc/C/rpc"],
                               blockExplorerUrls: ["https://snowtrace.io/"],
                               vmType: .EVM),
    .fuji : LITEVMChain(contractAddress: "0xc716950e5DEae248160109F562e1C9bF8E0CA25B",
                               chainId: 43113,
                               type: "ERC1155",
                               name: "Avalanche FUJI Testnet",
                               symbol: "AVAX",
                               decimals: 18,
                               rpcUrls: ["https://api.avax-test.network/ext/bc/C/rpc"],
                               blockExplorerUrls: ["https://testnet.snowtrace.io/"],
                               vmType: .EVM),
    .harmony : LITEVMChain(contractAddress: "0xBB118507E802D17ECDD4343797066dDc13Cde7C6",
                               chainId: 1666600000,
                               type: "ERC1155",
                               name: "Harmony",
                               symbol: "ONE",
                               decimals: 18,
                               rpcUrls: ["https://api.harmony.one"],
                               blockExplorerUrls: ["https://explorer.harmony.one/"],
                               vmType: .EVM),
    .kovan : LITEVMChain(contractAddress: "0x9dB60Db3Dd9311861D87D33B0463AaD9fB4bb0E6",
                               chainId: 42,
                               type: "ERC1155",
                               name: "Kovan",
                               symbol: "ETH",
                               decimals: 18,
                               rpcUrls: ["https://kovan.infura.io/v3/ddf1ca3700f34497bca2bf03607fde38"],
                               blockExplorerUrls: ["https://kovan.etherscan.io"],
                               vmType: .EVM),

    .mumbai: LITEVMChain(contractAddress: "0xc716950e5DEae248160109F562e1C9bF8E0CA25B",
                         chainId: 80001,
                         type: "ERC1155",
                         name: "Mumbai",
                         symbol: "MATIC",
                         decimals: 18,
                         rpcUrls: ["https://rpc-mumbai.maticvigil.com/v1/96bf5fa6e03d272fbd09de48d03927b95633726c"],
                         blockExplorerUrls: ["https://mumbai.polygonscan.com"],
                         vmType: .EVM),
    
    .goerli: LITEVMChain(contractAddress: "0xc716950e5DEae248160109F562e1C9bF8E0CA25B",
                         chainId: 5,
                         type: "ERC1155",
                         name: "Goerli",
                         symbol: "ETH",
                         decimals: 18,
                         rpcUrls: ["https://goerli.infura.io/v3/96dffb3d8c084dec952c61bd6230af34"],
                         blockExplorerUrls: ["https://goerli.etherscan.i"],
                         vmType: .EVM),
    
    .ropsten: LITEVMChain(contractAddress: "0x61544f0AE85f8fed6Eb315c406644eb58e15A1E7",
                         chainId: 3,
                         type: "ERC1155",
                         name: "Ropsten",
                         symbol: "ETH",
                         decimals: 18,
                         rpcUrls: ["https://ropsten.infura.io/v3/96dffb3d8c084dec952c61bd6230af34"],
                         blockExplorerUrls: ["https://ropsten.etherscan.io"],
                         vmType: .EVM),
    .rinkeby: LITEVMChain(contractAddress: "0xc716950e5deae248160109f562e1c9bf8e0ca25b",
                         chainId: 4,
                         type: "ERC1155",
                         name: "Rinkeby",
                         symbol: "ETH",
                         decimals: 18,
                         rpcUrls: ["https://rinkeby.infura.io/v3/96dffb3d8c084dec952c61bd6230af34"],
                         blockExplorerUrls: ["https://rinkeby.etherscan.io"],
                         vmType: .EVM),
    .cronos: LITEVMChain(contractAddress: "0xc716950e5DEae248160109F562e1C9bF8E0CA25B",
                         chainId: 25,
                         type: "ERC1155",
                         name: "Cronos",
                         symbol: "CRO",
                         decimals: 18,
                         rpcUrls: ["https://evm-cronos.org"],
                         blockExplorerUrls: ["https://cronos.org/explorer/"],
                         vmType: .EVM),
    .optimism: LITEVMChain(contractAddress: "0xbF68B4c9aCbed79278465007f20a08Fa045281E0",
                         chainId: 10,
                         type: "ERC1155",
                         name: "Optimism",
                         symbol: "ETH",
                         decimals: 18,
                         rpcUrls: ["https://mainnet.optimism.io"],
                         blockExplorerUrls: ["https://optimistic.etherscan.io"],
                         vmType: .EVM),
    .celo: LITEVMChain(contractAddress: "0xBB118507E802D17ECDD4343797066dDc13Cde7C6",
                         chainId: 42220,
                         type: "ERC1155",
                         name: "Celo",
                         symbol: "CELO",
                         decimals: 18,
                         rpcUrls: ["https://forno.celo.org"],
                         blockExplorerUrls: ["https://explorer.celo.org"],
                         vmType: .EVM),
    .aurora: LITEVMChain(chainId: 1313161554,
                         name: "Aurora",
                         symbol: "ETH",
                         decimals: 18,
                         rpcUrls: ["https://mainnet.aurora.dev"],
                         blockExplorerUrls: ["https://aurorascan.dev"],
                         vmType: .EVM),
    .eluvio: LITEVMChain(chainId: 955305,
                         name: "Eluvio",
                         symbol: "ELV",
                         decimals: 18,
                         rpcUrls: ["https://host-76-74-28-226.contentfabric.io/eth"],
                         blockExplorerUrls: ["https://explorer.eluv.io"],
                         vmType: .EVM),
    .alfajores: LITEVMChain(chainId: 44787,
                         name: "Alfajores",
                         symbol: "CELO",
                         decimals: 18,
                         rpcUrls: ["https://alfajores-forno.celo-testnet.org"],
                         blockExplorerUrls: ["https://alfajores-blockscout.celo-testnet.org"],
                         vmType: .EVM),
    .xdc: LITEVMChain(chainId: 50,
                         name: "XDC Blockchain",
                         symbol: "XDC",
                         decimals: 18,
                         rpcUrls: ["https://rpc.xinfin.network"],
                         blockExplorerUrls: ["https://explorer.xinfin.network"],
                         vmType: .EVM),
    .evmos: LITEVMChain(chainId: 9001,
                         name: "EVMOS",
                         symbol: "EVMOS",
                         decimals: 18,
                         rpcUrls: ["https://eth.bd.evmos.org:8545"],
                         blockExplorerUrls: ["https://evm.evmos.org"],
                         vmType: .EVM),
    .evmosTestnet: LITEVMChain(chainId: 9000,
                         name: "EVMOS Testnet",
                         symbol: "EVMOS",
                         decimals: 18,
                         rpcUrls: ["https://eth.bd.evmos.dev:8545"],
                         blockExplorerUrls: ["https://evm.evmos.dev"],
                         vmType: .EVM),
    
]


let LIT_SVM_CHAINS: LITChain<LITEVMChain> = [
    .solana : LITEVMChain(name: "Solana",
                          symbol: "SOL",
                          decimals: 9,
                          rpcUrls: ["https://api.mainnet-beta.solana.com"],
                          blockExplorerUrls: ["https://explorer.solana.com/"],
                          vmType: .SVM),
    .solanaDevnet : LITEVMChain(name: "Solana Devnet",
                          symbol: "SOL",
                          decimals: 9,
                          rpcUrls: ["https://api.devnet.solana.com"],
                          blockExplorerUrls: ["https://explorer.solana.com/"],
                                vmType: .SVM),
    .solanaTestnet : LITEVMChain(name: "Solana Testnet",
                          symbol: "SOL",
                          decimals: 9,
                          rpcUrls: ["https://api.testnet.solana.com"],
                          blockExplorerUrls: ["https://explorer.solana.com/"],
                                 vmType: .SVM)
]

let LIT_COSMOS_CHAINS: LITChain<LITEVMChain> = [
    .cosmos : LITEVMChain(chainId: "cosmoshub-4",
                             name: "Cosmos",
                             symbol: "ATOM",
                             decimals: 6,
                             rpcUrls: ["https://lcd-cosmoshub.keplr.app"],
                             blockExplorerUrls: ["https://atomscan.com/"],
                             vmType: .CVM),
    .kyve : LITEVMChain(chainId: "korellia",
                           name: "Kyve",
                           symbol: "KYVE",
                           decimals: 6,
                           rpcUrls: ["https://api.korellia.kyve.network"],
                           blockExplorerUrls: ["https://explorer.kyve.network/"],
                           vmType: .CVM),
    .evmosCosmos : LITEVMChain(chainId: "evmos_9001-2",
                           name: "EVMOS Cosmos",
                           symbol: "EVMOS",
                           decimals: 18,
                           rpcUrls: ["https://rest.bd.evmos.org:1317"],
                           blockExplorerUrls: ["https://evmos.bigdipper.live/"],
                           vmType: .CVM),
    .kyve : LITEVMChain(chainId: "evmos_9000-4",
                           name: "Evmos Cosmos Testnet",
                           symbol: "EVMOS",
                           decimals: 18,
                           rpcUrls: ["https://rest.bd.evmos.dev:1317"],
                           blockExplorerUrls: ["https://testnet.bigdipper.live"],
                           vmType: .CVM),
]

public enum Chain: String {
    /// LIT_CHAINS
    case ethereum
    case polygon
    case mumbai
    case fantom
    case xdai
    case bsc
    case arbitrum
    case avalanche
    case fuji
    case harmony
    case kovan
    case goerli
    case ropsten
    case rinkeby
    case cronos
    case optimism
    case celo
    case aurora
    case eluvio
    case alfajores
    case xdc
    case evmos
    case evmosTestnet

    /// LIT_SVM_CHAINS
    case solana
    case solanaDevnet
    case solanaTestnet
    
    /// LIT_COSMOS_CHAINS
    case cosmos
    case kyve
    case evmosCosmos
    case evmosCosmosTestnet
}

enum VMType: String {
    case EVM
    case SVM
    case CVM
}

enum SigType: String {
    case BLS
    case ECDSA
}

enum EitherType: String {
    case ERROR
    case SUCCESS
}

public typealias LITChain<T> = [Chain: T]

public class LITEVMChain {
    let contractAddress: String?
    let chainId: Any?
    let type: String?
    let name: String
    let symbol: String
    let decimals: Int
    public let rpcUrls: [String]
    let blockExplorerUrls: [String]
    let vmType: VMType
    init(contractAddress: String? = nil, chainId: Any? = nil, type: String? = nil, name: String, symbol: String, decimals: Int, rpcUrls: [String], blockExplorerUrls: [String], vmType: VMType) {
        self.contractAddress = contractAddress
        self.chainId = chainId
        self.type = type
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.rpcUrls = rpcUrls
        self.blockExplorerUrls = blockExplorerUrls
        self.vmType = vmType
    }
}
let LIT_SESSION_KEY_URI = "lit:session:"
