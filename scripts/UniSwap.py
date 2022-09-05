from brownie import *
from brownie_tokens import MintableForkToken

def main():

    # Import Token Addresses from brownie-config.yaml
    bat_addr = config["networks"][network.show_active()]["BAT"]
    usdc_addr = config["networks"][network.show_active()]["usdc_token"]
    link_addr = config["networks"][network.show_active()]["link_token"]
    curve_addr = config["networks"][network.show_active()]["curve"]
    comp_addr = config["networks"][network.show_active()]["comp_token"]
    aave_addr = config["networks"][network.show_active()]["aave"]
    dydx_addr = config["networks"][network.show_active()]["dydx"]
    bal_addr = config["networks"][network.show_active()]["balancer"]
    mana_addr = config["networks"][network.show_active()]["mana"]
    dai_addr = config["networks"][network.show_active()]["dai_token"]
    WETH  = config["networks"][network.show_active()]["weth_token"]


     # Import UniSwap Contract Addresses from brownie-config.yaml
    Factory_addr = config["networks"][network.show_active()]["UniSwapFactory"]
    Router_addr = config["networks"][network.show_active()]["UniSwapRouter"]
    Factory = interface.IUniswapV2Factory(Factory_addr)

    # tokens for address[] memory _tokens in constructor
    tokens=[bat_addr, link_addr, curve_addr, comp_addr, aave_addr, dydx_addr, bal_addr, mana_addr]

    # Create Test account (whale) & fund it with 1_000 Dai 
    whale = accounts[0]
    amount = 1_000 * 10 ** 18 # 1,000 DAI
    dai = mint(dai_addr, whale, amount)

    # Deploy FinalUniProject Contract, approve dai, and send dai to initialSwap function
    Contract = FinalUniProject.deploy(Router_addr, WETH, Factory_addr, tokens, {'from':accounts[0]})
    dai.approve(Contract.address, amount, {"from": whale})
    Contract.InitialSwap(dai_addr, WETH, amount)

    # Call FinalSwap function
    tx = Contract.FinalSwap(1)

    # Display event values to users: optimal UniSwap amounts 
    print("Optimal Swap Calculating...\n")
    for event in tx.events['OptimalSwap']:
         (Symbol, WethAmount) = event.values()
         print(f'\t{Symbol}\WETH Optimal Swap:\n\tAmount: {WethAmount/10**18} {Symbol}\n')



    # Display event values to users: LP pools, amounts, and recieved LP tokens 
    print("LPing into pools...\n")
    for event in tx.events['Log']:
        (Symbol, WethAmount, TokenAmount, LPtokenAmount)= event.values()
        print(f'\n\t{Symbol}\WETH pool:\n\tDeposited: {WethAmount/10**18} WETH and {TokenAmount/10**18} {Symbol}\n\tReceived: {LPtokenAmount/10**18} LP Tokens\n')

     # Enter two token in given liquidity pools to remove liquidity 

    # WETH/BAT pool
    txRemoveLiq = Contract.removeLiquidity(WETH, bat_addr)

    for event in txRemoveLiq.events['LiquidityRemove']:
        (Symbol, TokenAmount) = event[0].values()
        print(f'{Symbol} Earned: {TokenAmount/10**18}')



# Function to mint any crypto given its address and fund to a given user
def mint(coin_address, account, amount):
    # dai = MintableForkToken.from_explorer("0x6b175474e89094c44da98b954eedeac495271d0f")
    coin = MintableForkToken.from_explorer(coin_address)
    #dai._mint_for_testing(whale, amount)
    coin._mint_for_testing(account, amount)
    return coin

            
        

