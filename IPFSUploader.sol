pragma solidity ^0.5.11;

import "./provableAPI.sol";

contract IPFSUploader is usingProvable  {

    address public owner;
    string public IPFSHash;
    string public provableComputationHash;
    mapping(bytes32=>bool) validIds;
    event LogConstructorInitiated(string nextStep);
    event LogNewProvableQuery(string description);
    event LogIPFSHashReceived(string hash);
    
    modifier ownerOnly() {
      if (msg.sender == owner) _;
    }

    
    constructor () public payable  {
        owner = msg.sender;
        
        provableComputationHash = "QmRGYcLzFhLqBaVVBcMdQmF25XCSCA7i6KgfiWtp5Mfn9Y";
        
        provable_setCustomGasPrice(4000000000);
        provable_setProof(proofType_TLSNotary | proofStorage_IPFS);
        emit LogConstructorInitiated("Constructor was initiated. Call 'uploadToIPFS(text)' to send the Provable Query.");
    }
    
    function setProvableComputationHash(string memory _provableComputationHash) public ownerOnly
    {
        provableComputationHash = _provableComputationHash;
    }

    function __callback(bytes32 _myid, string memory _result, bytes memory _proof) public {
        if (!validIds[_myid]) revert();
        if (msg.sender != provable_cbAddress()) revert();
        IPFSHash = _result;
        emit LogIPFSHashReceived(_result);
        delete validIds[_myid];
    }

    function uploadToIPFS(string memory _text, string memory _filename) public payable {
        if (provable_getPrice("computation") > address(this).balance) {
          emit LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
          emit LogNewProvableQuery("Provable query was sent, standing by for the answer..");
          bytes32 queryId =
            provable_query("computation", [provableComputationHash, _text, _filename]);
          validIds[queryId] = true;
        }
    }
}
