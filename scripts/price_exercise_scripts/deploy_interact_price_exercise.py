#!/usr/bin/python3
from brownie import PriceExercise, config, network

from scripts.helpful_scripts import (
    get_account,
    get_verify_status,
    get_contract,
)

def deploy_price_feed():
    jobId = config["networks"][network.show_active()]["jobId"]
    fee = config["networks"][network.show_active()]["fee"]
    account = get_account()
    oracle = get_contract("oracle").address
    link_token = get_contract("link_token").address
    
    price_exercise = PriceExercise.deploy(
        {"from": account}
    )
    print(f"PriceExercise deployed to {price_exercise.address}")
    return price_exercise


def main():
    price_exercise = deploy_price_feed()
    price_exercise.setValue(23)
    print(price_exercise.getValue())
