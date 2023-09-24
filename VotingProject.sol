// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Election {
    address public owner;
    enum ElectionState { NOT_STARTED, ONGOING, ENDED }
    ElectionState public electionState;

    struct Candidate {
        uint256 id;
        string name;
        string proposal;
        uint256 voteCount;
        address candidateAddress; // Address of the candidate
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedForCandidateId;
        address delegate;
        address voterAddress; // Address of the voter
    }

    mapping(uint256 => Candidate) public candidates;
    uint256 public candidateCount;

    mapping(address => Voter) public voters;
    uint256 public voterCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier electionOngoing() {
        require(electionState == ElectionState.ONGOING, "Election is not ongoing.");
        _;
    }

    modifier voterNotVoted() {
        require(!voters[msg.sender].hasVoted, "Voter has already cast their vote.");
        _;
    }

    constructor() {
        owner = msg.sender;
        electionState = ElectionState.NOT_STARTED;
    }

    function addCandidate(string memory _name, string memory _proposal) public onlyOwner {
        require(electionState == ElectionState.NOT_STARTED, "Cannot add candidates after the election starts.");
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, _proposal, 0, msg.sender);
    }

    function addVoter(address _voter) public onlyOwner {
        require(electionState == ElectionState.NOT_STARTED, "Cannot add voters after the election starts.");
        require(!voters[_voter].isRegistered, "Voter has already been added.");
        voterCount++;
        voters[_voter] = Voter(true, false, 0, address(0), _voter);
    }

    function startElection() public onlyOwner {
        require(electionState == ElectionState.NOT_STARTED, "Election has already started or ended.");
        electionState = ElectionState.ONGOING;
    }

    function endElection() public onlyOwner {
        require(electionState == ElectionState.ONGOING, "Election has not yet started or has already ended.");
        electionState = ElectionState.ENDED;
    }

    function delegateVote(address _delegate) public electionOngoing voterNotVoted {
        require(_delegate != msg.sender, "You cannot delegate voting rights to yourself.");
        require(voters[_delegate].isRegistered, "Delegate is not a registered voter.");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].delegate = _delegate;
    }

    function vote(uint256 _candidateId) public electionOngoing voterNotVoted {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID.");
        require(voters[msg.sender].delegate == address(0), "Delegated voters cannot cast votes directly.");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedForCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
    }

    function displayCandidateDetails(uint256 _candidateId) public view returns (uint256, string memory, string memory) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID.");
        return (candidates[_candidateId].id, candidates[_candidateId].name, candidates[_candidateId].proposal);
    }

    function getVoter(address _voterAddress) public view returns (bool, bool, uint256, address) {
        Voter memory voter = voters[_voterAddress];
        return (voter.isRegistered, voter.hasVoted, voter.votedForCandidateId, voter.delegate);
    }

    function showResults(uint256 _candidateId) public view returns (uint256, string memory, uint256, address) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID.");
        return (candidates[_candidateId].id, candidates[_candidateId].name, candidates[_candidateId].voteCount, candidates[_candidateId].candidateAddress);
    }

    function showWinner() public view returns (string memory, uint256, uint256, address) {
        require(electionState == ElectionState.ENDED, "Election is ongoing or has not yet started.");
        Candidate memory winner = candidates[1];
        for (uint256 i = 2; i <= candidateCount; i++) {
            if (candidates[i].voteCount > winner.voteCount) {
                winner = candidates[i];
            }
        }
        return (winner.name, winner.id, winner.voteCount, winner.candidateAddress);
    }

    function voterProfile() public view returns (bool, bool, uint256, address) {
        Voter memory voter = voters[msg.sender];
        return (voter.isRegistered, voter.hasVoted, voter.votedForCandidateId, voter.delegate);
    }
}
