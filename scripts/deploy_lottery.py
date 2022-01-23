from brownie import Lottery
from scripts.helpful_scripts import get_account, get_contract
 
def deploy_lottery():
    account = get_account(id="browniefundme-account")
    lottery = Lottery.Deploy(get_contract("eth_usd_price_feed").address)

def main():
    deploy_lottery();