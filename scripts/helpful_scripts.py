from brownie import accounts, network, config
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "local-ganache"]

def get_account(index=None, id=None):
    if index:
        return accounts[index]
    elif id:
         return accounts.load(id)
     
def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("Deploying mocks...")
    #MockV3Aggregator.deploy(DECIMALS,INITIAL_VALUE,{'from':get_account()})
    print ("mocks deployed!")
             
 