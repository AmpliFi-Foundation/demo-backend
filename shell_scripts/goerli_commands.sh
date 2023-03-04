export env/goerli.env

forge script script/01_Deploy.s.sol:Deploy --private-key=$(cat ~/goerli.secret) --rpc-url='https://eth-goerli.g.alchemy.com/v2/VSMEH5UxQUVsV-N_CDJUqXfdiN3cNdJc'

forge script script/01_Deploy.s.sol:Deploy --private-key=$(cat ~/goerli.secret) --rpc-url='https://eth-goerli.g.alchemy.com/v2/VSMEH5UxQUVsV-N_CDJUqXfdiN3cNdJc' --broadcast --verify