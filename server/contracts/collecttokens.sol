pragma solidity ^0.4.24;

contract Request{
uint public counter=0;
struct Request {
string request_id;
address requestor;
address acceptor;
string description;
uint servicevalue;
uint tokens;
string status;
uint16 req_approval;
uint16 appr_approval;
}

struct user {
    string[] requests;
    string[] approvers;
    uint tokens;
}

mapping (string => Request) private requests;
mapping (address => user) private user_data;
//mapping (address => approvers_arr)  public approve_requests;
address public superuser;

modifier restricted() {
        require(msg.value !=0);
        _;
    }

  function uint2str(uint i) internal pure returns (string){
    if (i == 0) return "0";
    uint j = i;
    uint length;
    while (j != 0){
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint k = length - 1;
    while (i != 0){
        bstr[k--] = byte(48 + i % 10);
        i /= 10;
    }
    return string(bstr);
}

function createrequest(string ipfsdesc,uint servicevalue,uint tokens) public restricted  payable{
    string memory request_id_gen=uint2str(counter);
Request memory newRequest= Request({
request_id:request_id_gen,
requestor:msg.sender,
acceptor :0x0,
description:ipfsdesc,
servicevalue:servicevalue,
tokens:tokens,
status:"Available",
req_approval:0,
appr_approval:0
});
counter++;
requests[request_id_gen]=newRequest;
user_data[msg.sender].requests.push(request_id_gen);
user_data[msg.sender].tokens=requests[request_id_gen].tokens;
}

function viewRequest(uint index)  view public  returns(string,string,address)
{
    return (requests[user_data[msg.sender].requests[index]].request_id,
            requests[user_data[msg.sender].requests[index]].description,
            requests[user_data[msg.sender].requests[index]].acceptor);
    
}

function approve_request(string req_id)   public {
    requests[req_id].acceptor=msg.sender;
    requests[req_id].status="In Process";
    user_data[msg.sender].approvers.push(req_id);
    user_data[msg.sender].tokens=requests[req_id].tokens;
    
}

function complete_request(string req_id) public
{
    if(msg.sender==requests[req_id].acceptor){
        requests[req_id].appr_approval=1;
    }
    else{
        requests[req_id].req_approval=1;
    }
    
    if(requests[req_id].req_approval==1&&requests[req_id].appr_approval==1){
       requests[req_id].acceptor.transfer(requests[req_id].servicevalue);
        user_data[requests[req_id].acceptor].tokens=0;
        user_data[requests[req_id].requestor].tokens=0;
        requests[req_id].status="Completed";
    }
}
}