-include .env

KEY_NAME = zingKey
SENDER_ADDRESS = 0xDdE95e58D3210174D7Cd6D8dC3D3e370C5a4b49A

# Create a new private key
createKey:
	cast wallet new

# To store the private key in a key store, we need to use the following command:
storeKey:
	cast wallet import $(KEY_NAME) --interactive

viewKey:
	cast wallet view $(KEY_NAME) --interactive

deployContract:
	forge script script/DeployZing.s.sol --rpc-url $(RPC_URL) --account $(KEY_NAME) --sender $(SENDER_ADDRESS) --broadcast

deployContractOnSepolia:
	forge script script/DeployZing.s.sol --rpc-url $(SEPOLIA_RPC_URL) \
	--account $(KEY_NAME) --sender $(SENDER_ADDRESS) --broadcast

deployContractOnBNBTestnet:
	forge script script/DeployZing.s.sol --rpc-url $(BNB_TESTNET_RPC_URL) \
	--account $(KEY_NAME) --sender $(SENDER_ADDRESS) --broadcast

deployContractOnAvaxFuji:
	forge script script/DeployZing.s.sol --rpc-url $(AVAX_FUJI_RPC_URL) \
	--account $(KEY_NAME) --sender $(SENDER_ADDRESS) --broadcast

deployContractOnAvaxMainnet:
	forge script script/DeployZing.s.sol --rpc-url $(AVAX_MAINNET_RPC_URL) \
	--account $(KEY_NAME) --sender $(SENDER_ADDRESS) --broadcast

deployContractOnArbitrumMainnet:
	forge script script/DeployZing.s.sol --rpc-url $(ARB_MAINNET_RPC_URL) \
	--account $(KEY_NAME) --sender $(SENDER_ADDRESS) --broadcast
