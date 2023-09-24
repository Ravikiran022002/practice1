// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MigrantWorkerDapp {
    address public admin;
    
    enum ApplicantType { Unskilled, SemiSkilled, Skilled }
    
    struct Applicant {
        string name;
        ApplicantType appType;
        string laborHistory;
        string skills;
        bool isAvailable;
        uint rating;
    }
    
    struct Job {
        uint jobId;
        string jobTitle;
        string description;
        bool isClosed;
    }

    mapping(address => Applicant) public applicants;
    Job[] public jobs;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }
    
    modifier onlyApplicant() {
        require(applicants[msg.sender].appType != ApplicantType(0), "Only applicants can call this function.");
        _;
    }
    
    event NewApplicantAdded(address indexed applicantAddress, string name);
    event NewJobAdded(uint indexed jobId, string jobTitle);
    event JobApplication(address indexed applicantAddress, uint indexed jobId);
    event JobClosed(uint indexed jobId, string jobTitle);
    event RatingGiven(address indexed applicantAddress, uint rating);
    
    constructor() {
        admin = msg.sender;
    }
    
    function addApplicant(
        string memory _name,
        uint8 _appType,
        string memory _laborHistory,
        string memory _skills,
        bool _isAvailable
    ) external onlyAdmin {
        applicants[msg.sender] = Applicant(
            _name,
            ApplicantType(_appType),
            _laborHistory,
            _skills,
            _isAvailable,
            0
        );
        emit NewApplicantAdded(msg.sender, _name);
    }
    
    function addJob(string memory _jobTitle, string memory _description) external onlyAdmin {
        uint jobId = jobs.length;
        jobs.push(Job(jobId, _jobTitle, _description, false));
        emit NewJobAdded(jobId, _jobTitle);
    }
    
    function applyForJob(uint _jobId) external onlyApplicant {
        require(_jobId < jobs.length, "Invalid job ID");
        require(!jobs[_jobId].isClosed, "Job is closed");
        emit JobApplication(msg.sender, _jobId);
    }
    
    function closeJob(uint _jobId) external onlyAdmin {
        require(_jobId < jobs.length, "Invalid job ID");
        jobs[_jobId].isClosed = true;
        emit JobClosed(_jobId, jobs[_jobId].jobTitle);
    }
    
    function rateApplicant(address _applicantAddress, uint _rating) external onlyAdmin {
        require(applicants[_applicantAddress].appType != ApplicantType(0), "Invalid applicant");
        require(_rating >= 0 && _rating <= 5, "Invalid rating");
        applicants[_applicantAddress].rating = _rating;
        emit RatingGiven(_applicantAddress, _rating);
    }
    
    function getApplicantRating(address _applicantAddress) external view returns (uint) {
        require(applicants[_applicantAddress].appType != ApplicantType(0), "Invalid applicant");
        return applicants[_applicantAddress].rating;
    }
}


//This contract allows an admin to add new applicants, add new jobs, close jobs, and rate applicants.
// Applicants can apply for jobs, and the contract keeps track of their details, including ratings. Again, this is a basic template, and real-world 
//applications would require more complex functionalities, security measures, and potentially optimizations depending on the scale of the Dapp.