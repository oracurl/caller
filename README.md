# ORAcURL Caller Contract

This contract is meant to be inherited by any Solidity smart contract that wants to use the [ORAcURL.com](https://oracurl.com) oracle service. 

**This service is currently in Pre Alpha, and it connects to the Goerli testnet only.**

## How to use

First go to [ORAcURL.com](https://oracurl.com) and register if necessary. Then register a new cURL call there and make note of the Endpoint ID that is generated there for you. For more information, visit [enter link description here](https://oracurl.com/learn-how-to#be-creator-workflow)

First import the ORAcURLCaller Contract:

    import "https://github.com/oracurl/caller/blob/v0.0.1/OraCURLCaller.sol";

Next inherit the contract 

    contract MyContract is ORAcURLCaller { /* your code here */ }

Add the function that will call the oracle function. Make sure it is payable or that your contract is able to send eth as it is expected that it sends enough eth to pay the gas for the trip back from the oracle to your contract plus a tip for the actor who executes the cURL.

    function MyFunction() public payable {
        //the endpoint id that you receive after registering a cURL
        uint128 endpointId = 5467710208341867;

        cURL(
	        endpointId,
	        //name of your callback function that will receive the response
	        'callback',
	        //data to be inserted as a parameter in your cURL call
	        'data'
        );
    }

Finally you define your callback function, that will be triggered and receive the response from the oracle.

    function callback(bytes32 callID, bytes32 response) 
        public handlesCallback(callID,response) {
        
        /* Do something with response here */
    }
