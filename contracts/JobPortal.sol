// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JobPortal {
    address public admin;

    enum WorkPreference { NotSpecified, Remote, WFH, Hybrid }

    struct Applicant {
        uint256 id;
        string name;
        string skills;
        string phoneNumber;
        string email;
        uint256 rating;
        WorkPreference workPreference;
    }

    struct Job {
        uint256 id;
        string title;
        string description;
        uint256 salary;
        uint256 applicantId;
        bool isFilled; // Indicates whether the job is already filled
    }

    Applicant[] public allApplicants;  // Array to store all applicants
    Job[] public allJobs;  // Array to store all jobs

    mapping(address => mapping(uint256 => bool)) public jobApplications;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute this");
        _;
    }

    modifier onlyAdminOrContract() {
        require(msg.sender == admin || msg.sender == address(this), "Not authorized");
        _;
    }

    event NewApplicant(uint256 applicantId, string name, string skills, string phoneNumber, string email, WorkPreference workPreference);
    event NewJob(uint256 jobId, string title, string description, uint256 salary);
    event JobApplication(uint256 jobId, uint256 applicantId);
    event JobHired(uint256 jobId, uint256 applicantId);
    event RatingGiven(uint256 applicantId, uint256 rating);
    event WorkPreferenceUpdated(uint256 applicantId, WorkPreference workPreference);

    constructor() {
        admin = msg.sender;
    }

    function addApplicant(string memory _name, string memory _skills, string memory _phoneNumber, string memory _email, WorkPreference _workPreference) public onlyAdmin {
        uint256 applicantId = allApplicants.length + 1;
        allApplicants.push(Applicant(applicantId, _name, _skills, _phoneNumber, _email, 0, _workPreference));
        emit NewApplicant(applicantId, _name, _skills, _phoneNumber, _email, _workPreference);
    }

    function addJob(string memory _title, string memory _description, uint256 _salary) public onlyAdmin {
        uint256 jobId = allJobs.length + 1;
        allJobs.push(Job(jobId, _title, _description, _salary, 0, false));
        emit NewJob(jobId, _title, _description, _salary);
    }

    function applyForJob(uint256 _jobId) public {
        require(msg.sender != admin, "Admin cannot apply for a job");
        require(_jobId <= allJobs.length, "Invalid job ID");
        require(!allJobs[_jobId - 1].isFilled, "Job already filled");
        require(!jobApplications[msg.sender][_jobId], "Already applied for this job");

        jobApplications[msg.sender][_jobId] = true;

        uint256 applicantId = allApplicants.length;
        emit JobApplication(_jobId, applicantId);
    }

    function hireApplicant(uint256 _jobId, uint256 _applicantId) public onlyAdmin {
        require(_jobId <= allJobs.length && _applicantId <= allApplicants.length, "Invalid job or applicant ID");
        require(!allJobs[_jobId - 1].isFilled, "Job already filled");

        allJobs[_jobId - 1].applicantId = _applicantId;
        allJobs[_jobId - 1].isFilled = true;

        allApplicants[_applicantId - 1].rating++;
        emit JobHired(_jobId, _applicantId);
    }

    function provideRating(uint256 _applicantId, uint256 _rating) public onlyAdmin {
        require(_applicantId <= allApplicants.length, "Invalid applicant ID");
        require(_rating >= 0 && _rating <= 5, "Rating must be between 0 and 5");

        allApplicants[_applicantId - 1].rating += _rating;
        emit RatingGiven(_applicantId, _rating);
    }

    function updateWorkPreference(uint256 _applicantId, WorkPreference _workPreference) public onlyAdminOrContract {
        require(_applicantId <= allApplicants.length, "Invalid applicant ID");

        allApplicants[_applicantId - 1].workPreference = _workPreference;
        emit WorkPreferenceUpdated(_applicantId, _workPreference);
    }

    function getApplicantDetails(uint256 _applicantId) public view returns (uint256, string memory, string memory, string memory, string memory, uint256, WorkPreference) {
        require(_applicantId <= allApplicants.length, "Invalid applicant ID");

        Applicant memory applicant = allApplicants[_applicantId - 1];
        return (applicant.id, applicant.name, applicant.skills, applicant.phoneNumber, applicant.email, applicant.rating, applicant.workPreference);
    }

    function getJobDetails(uint256 _jobId) public view returns (uint256, string memory, string memory, uint256, uint256, bool) {
        require(_jobId <= allJobs.length, "Invalid job ID");

        Job memory job = allJobs[_jobId - 1];
        return (job.id, job.title, job.description, job.salary, job.applicantId, job.isFilled);
    }

    function getApplicantRating(uint256 _applicantId) public view returns (uint256) {
        require(_applicantId <= allApplicants.length, "Invalid applicant ID");

        return allApplicants[_applicantId - 1].rating;
    }

    function getAllApplicants() public view returns (Applicant[] memory) {
        return allApplicants;
    }

    function getApplicantType(uint256 _applicantId) public view returns (WorkPreference) {
        require(_applicantId <= allApplicants.length, "Invalid applicant ID");

        return allApplicants[_applicantId - 1].workPreference;
    }

    function getAllJobDetails() public view returns (Job[] memory) {
        return allJobs;
    }
}
