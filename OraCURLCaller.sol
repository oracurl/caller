//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ORAcURLCaller {
    //dispatcher proxy contract address
    DispatcherInterface public dispatcher = DispatcherInterface(0x9565B24fbe3E386191B61f56cC6249ECFF3ab489);
    address dispatcherAddress = 0x9565B24fbe3E386191B61f56cC6249ECFF3ab489;
    //DispatcherInterface public dispatcher;
    bool internal useLocalQueueFeatures = true;
    //internal queue
    mapping(bytes32 => uint) localQueueMap;
    bytes32[] localQueueArray;
    
    event CalledBack(
        bytes32 callID,
        bytes32 response
    );
    /*
    * cURL receives the endpointID, the name of the callback function, and vars to be sent in the cURL
    * 
    * You can optionally specify the wei to send for the trip back + tip as a parameter, otherwise it will send all of msg.value 
    */
    function cURL(uint128 _endpointID, bytes32 _callback, bytes32 _calldata, uint _value) internal returns(bytes32, uint) {
        //todo: verify
        //nonce to be able to re-try or unstick a call with insufficient funds
        uint _nonce = 0;
        //create callID using hash of this contract's address + timestamp
        bytes32 _callID = keccak256(abi.encodePacked(
            _endpointID, _callback, _calldata, _nonce, block.timestamp));
        //change state
        if(useLocalQueueFeatures){
            localQueueMap[_callID] = _nonce;
            localQueueArray.push(_callID);
        }
        if(_value == 0){
            _value = msg.value;
        }
        require(_value > 0, "Insufficient funds.");
        //require(
        dispatcher.cURL{value: _value}(
            _endpointID, _callID, _callback, _nonce, _calldata    
        );
        //);
        return (_callID, _nonce);
    }
    function cURL(uint128 _endpointID, bytes32 _callback, bytes32 _calldata) internal returns(bytes32, uint) {
        uint _value = 0;
        return cURL(_endpointID,  _callback,  _calldata, _value);
    }
    function cURL(uint128 _endpointID, bytes32 _callback) internal returns(bytes32, uint){
        uint _value = 0;
        bytes32 _calldata;
        return cURL(_endpointID,  _callback,  _calldata, _value);
    }
    modifier handlesCallback(bytes32 _callID, bytes32 _response){
        //callback can only be called by the proxy contract address
        require(msg.sender == dispatcherAddress);
        emit CalledBack(_callID, _response);
        _;
    }
    function recoverTip() internal{
        //call collectGarbage to recover remaining gwei (including tip)
    }
    function nudge() public payable {
        //send additional funds to a curl that is stuck
        // https://www.quiknode.io/guides/web3-sdks/how-to-re-send-a-transaction-with-higher-gas-price-using-ethers-js
    }
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}

contract DispatcherInterface {
    event addedToQueue(
        //endpointID
        uint128 endpointID,
        //callID
        bytes32 callID,
        //nonce
        uint nonce,
        //callback
        bytes32 callback,
        //parameters should be sent, but not indexed
        bytes32 payload
    );
    uint128 minimumTip;
    uint48 timeoutInSeconds;
    address public authorizer;
    mapping(bytes32 => uint) queue;
    constructor() {}
    function cURL(
        uint128 _endpointID, bytes32 _callID, bytes32 _callback, 
        uint _nonce, bytes32 payload) 
        public  payable {}
}