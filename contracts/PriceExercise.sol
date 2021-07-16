pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract PriceExercise is ChainlinkClient{

    bool public priceFeedGreater;
    uint public value = 0;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Kovan
     * Aggregator: BTC/USD
     * Address: 0x6135b13325bfC4B00278B4abC5e20bbce2D6580e
     */
    /**
     * Network: Mainnet
     * Aggregator: BTC/USD
     * Address: 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c
     */
    constructor(address _oracle, string memory _jobId, uint256 _fee, address _link, address AggregatorAddress) public {
        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        // oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
        // jobId = "29fa9aa13bf1468788b7cc4a500a45b8";
        // fee = 0.1 * 10 ** 18; // 0.1 LINK
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee;
        priceFeed = AggregatorV3Interface(AggregatorAddress);
    }

    function fulfill(bytes32 _requestId, int256 _price) public recordChainlinkFulfillment(_requestId) {
        // The ‘fulfill’ function should compare the returned value from cryptocompare to the current price of the BTC/USD price feed using an if/else statement 
        // (hint: syntax for if/else can be seen in the APIConsumer constructor). The price feed current price can be accessed by calling the getLatestPrice() function in your contract.
        int256 cryptoComparePrice = _price;
        int256 chainLinkPrice = getLatestPrice();
        if (chainLinkPrice > cryptoComparePrice) {
            priceFeedGreater = true;
        } else {
            priceFeedGreater = false;
        }
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestPriceData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD");
        
        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"ETH":
        //    {"USD":
        //     {
        //      "PRICE": 32062.2,
        //      "VOLUME24HOUR": xxx.xxx
        //     }
        //    }
        //   }
        //  }
        request.add("path", "RAW.BTC.USD.PRICE");
        
        // Multiply the result by 1000000000000000000 to remove decimals
        int timesAmount = 10**18;
        request.addInt("times", timesAmount);
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function setValue(uint _num) public {
        value = _num;
    }

    function getValue() public view returns (uint){
        return value;
    }

}