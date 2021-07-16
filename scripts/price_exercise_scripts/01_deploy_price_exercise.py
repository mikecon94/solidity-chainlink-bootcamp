#!/usr/bin/python3
from brownie import PriceExercise, MockV3Aggregator, config, network
from scripts.helpful_scripts import (
    get_account,
    get_verify_status,
    get_contract
)

def deploy_price_exercise_consumer():
    jobId = config["networks"][network.show_active()]["jobId"]
    fee = config["networks"][network.show_active()]["fee"]
    account = get_account()
    oracle = get_contract("oracle").address
    link_token = get_contract("link_token").address
    btc_usd_price_feed_address = get_contract("btc_usd_price_feed").address
    price_feed = PriceExercise.deploy(
        oracle,
        jobId,
        fee,
        link_token,
        btc_usd_price_feed_address,
        {"from": account},
        publish_source=get_verify_status(),
    )
    print(f"API Consumer deployed to {price_feed.address}")
    return price_feed

def main():
    deploy_price_exercise_consumer()
