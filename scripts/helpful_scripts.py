from brownie import accounts, network, config, MockV3Aggregator, Contract
from web3 import

FORKED_LOCAL_ENVIRONMENTS = ["mainet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "local-ganache"]

DECIMALS = 8
# This is 2,000
INITIAL_VALUE = 200000000000

def get_account(index=None, id=None):
    if index:
        return accounts[index]
    elif id:
         return accounts.load(id)
     
def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_VALUE):
    print(f"The active network is {network.show_active()}")
    print("Deploying mocks...")
    MockV3Aggregator.deploy(DECIMALS,INITIAL_VALUE,{'from':get_account()})
    print ("mocks deployed!")

contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator
}
             
def get_contract(contract_name):
    """
    This function will grab the contract addresess from the brownie config if defined
    Otherwise it will deploy a mock version of that contract, and return that mock contract
    
    Args:
    contract_name(string)
    
    Returns:
    brownie.network.contract.ProjectContract:The most recently deployed version of the contract
    """
    contract_type = contract_to_mock[contract_name]

    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
                deploy_mocks()
        contract = contract_type[-1]
        print("Deployed")
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(contract_type.name, contract_address, contract_type.abi)
    return contract
        
         
     
 
     