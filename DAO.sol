// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
contract practice{
    struct proporsal{
        uint id;
        string description;
        uint amount;
        address payable reciepient;
        uint votes; 
        uint end;
        bool isExecuted;
    }
    mapping(address=>bool)private isInvestor;
    mapping(address=>uint)public numOfShares; 
    mapping(address=>mapping(uint=>bool))  public isVoted;
    mapping(address =>mapping(address=>bool))public withdrawIsStatus;
    address[] public investorList;
    mapping(uint=>proporsal) public proporsals;

    uint public totalShares;
    uint public availableFunds;
    uint public contributionTimeEnd;
    uint public nextProporsalId;
    uint public voteTime;
    uint public quorum;
    address public manager;

    constructor(uint _contributionTimeEnd,uint _voteTime,uint _quorum){
        require(_quorum >0 && _quorum<100,"not valid Values");
        contributionTimeEnd= block.timestamp+_contributionTimeEnd;
        voteTime=_voteTime;
        quorum=_quorum;
        manager=msg.sender;   
    }

    modifier onlyInvestor(){
        require(isInvestor[msg.sender]==true,"You are not an Investor");
        _;
    }
    modifier onlyManager(){
        require(manager==msg.sender,"You are not a Manager");
        _;

    }
    function contribution()public payable {
        require(contributionTimeEnd>=block.timestamp,"Contribution Time Ended");
        require(msg.value>0,"send more than 0 ether"); 
        isInvestor[msg.sender]=true;
        numOfShares[msg.sender]=numOfShares[msg.sender]+msg.value;
        totalShares+=msg.value;
        availableFunds+=msg.value;
        investorList.push(msg.sender); 
    }

    function reedemShare(uint amount) public onlyInvestor(){
        require(numOfShares[msg.sender]>=amount,"you don't have enough funds");
        require(availableFunds>=amount,"we dont have enough funds");
        numOfShares[msg.sender]-=amount;
        if(numOfShares[msg.sender]==0){
            isInvestor[msg.sender]=false;
            
        }
        availableFunds-=amount;
        payable (msg.sender).transfer(amount);
    }
    function transferShare(uint amount,address  to) public onlyInvestor(){
    require(numOfShares[msg.sender]>=0,"you don't have enough funds");
    require(availableFunds>=amount,"we dont have enough funds");
    numOfShares[msg.sender]-=amount;
    if(numOfShares[msg.sender]==0){
        isInvestor[msg.sender]=false;
    }
    availableFunds-=amount;
    numOfShares[to]+=amount;
    isInvestor[to]=true;
    investorList.push(to);

    }
    function createProporsal(string calldata description, uint amount,address payable reciepient) onlyManager public{
        require (availableFunds>=amount,"not enough funds");
        proporsals[nextProporsalId]=proporsal(nextProporsalId,description,amount,reciepient,0,block.timestamp+voteTime,false);
        nextProporsalId++;
    }
    function voteProporsal(uint proporsalId) public onlyInvestor(){
        proporsal storage Proporsal=proporsals[proporsalId];
        require(isVoted[msg.sender][proporsalId]==false,"you have already voted");
        require(Proporsal.end>=block.timestamp,"voting time ended");
        require(Proporsal.isExecuted==false,"it is already executed");
        isVoted[msg.sender][proporsalId]=true;
        Proporsal.votes+=numOfShares[msg.sender];


    }
    function executeProporsal(uint proporsalId) public onlyManager(){
        proporsal storage Proporsal = proporsals[proporsalId];
        require(((Proporsal.votes*100)/totalShares)>=quorum,"majority doesnot support");
        Proporsal.isExecuted=true;
        availableFunds-=Proporsal.amount;
        _transfer(Proporsal.amount,Proporsal.reciepient);
    }
    function _transfer(uint amount, address payable reciepient) public {
        reciepient.transfer(amount);
       
    }
    function ProporsalList() public view returns(proporsal[] memory){
        proporsal[] memory arr = new proporsal[](nextProporsalId-1); 
        for (uint i=0;i<nextProporsalId;i++){
            arr[i]=proporsals[i];
        }
        return arr;
    }





       








    }