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

    mapping(uint256 => Applicant) public applicants;
    uint256 public applicantCount;

    mapping(uint256 => Job) public jobs;
    uint256 public jobCount;

    mapping(address => mapping(uint256 => bool)) public jobApplications;

    modifier onlyAdmin() {
        // Modifier to ensure that the caller is the admin
        require(msg.sender == admin, "Only admin can execute this");
        _;
    }

    modifier onlyAdminOrContract() {
        // Modifier to ensure that the caller is either the admin or the contract itself
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

    // Function to add a new applicant (only admin)
    function addApplicant(string memory _name, string memory _skills, string memory _phoneNumber, string memory _email, WorkPreference _workPreference) public onlyAdmin {
        applicantCount++;
        applicants[applicantCount] = Applicant(applicantCount, _name, _skills, _phoneNumber, _email, 0, _workPreference);
        emit NewApplicant(applicantCount, _name, _skills, _phoneNumber, _email, _workPreference);
    }

    // Function to add a new job (only admin)
    function addJob(string memory _title, string memory _description, uint256 _salary) public onlyAdmin {
        jobCount++;
        jobs[jobCount] = Job(jobCount, _title, _description, _salary, 0, false);
        emit NewJob(jobCount, _title, _description, _salary);
    }

    // Function to apply for a job
    function applyForJob(uint256 _jobId, uint256 _applicantId) public {
        require(_jobId <= jobCount && _applicantId <= applicantCount, "Invalid job or applicant ID");
        require(!jobs[_jobId].isFilled, "Job already filled");
        require(!jobApplications[msg.sender][_jobId], "Already applied for this job");

        jobApplications[msg.sender][_jobId] = true;
        emit JobApplication(_jobId, _applicantId);
    }

    // Function to hire an applicant (only admin)
    function hireApplicant(uint256 _jobId, uint256 _applicantId) public onlyAdmin {
        require(_jobId <= jobCount && _applicantId <= applicantCount, "Invalid job or applicant ID");
        require(!jobs[_jobId].isFilled, "Job already filled");

        jobs[_jobId].applicantId = _applicantId;
        jobs[_jobId].isFilled = true;

        applicants[_applicantId].rating++;
        emit JobHired(_jobId, _applicantId);
    }

    // Function to provide a rating to an applicant (only admin)
    function provideRating(uint256 _applicantId, uint256 _rating) public onlyAdmin {
        require(_applicantId <= applicantCount, "Invalid applicant ID");
        require(_rating >= 0 && _rating <= 5, "Rating must be between 0 and 5");

        applicants[_applicantId].rating += _rating;
        emit RatingGiven(_applicantId, _rating);
    }

    // Function to update work preference (admin or the contract itself)
    function updateWorkPreference(uint256 _applicantId, WorkPreference _workPreference) public onlyAdminOrContract {
        require(_applicantId <= applicantCount, "Invalid applicant ID");

        // Update the work preference
        applicants[_applicantId].workPreference = _workPreference;
        emit WorkPreferenceUpdated(_applicantId, _workPreference);
    }

    // Function to get details of an applicant
    function getApplicantDetails(uint256 _applicantId) public view returns (uint256, string memory, string memory, string memory, string memory, uint256, WorkPreference) {
        require(_applicantId <= applicantCount, "Invalid applicant ID");

        Applicant memory applicant = applicants[_applicantId];
        return (applicant.id, applicant.name, applicant.skills, applicant.phoneNumber, applicant.email, applicant.rating, applicant.workPreference);
    }

    // Function to get details of a job
    function getJobDetails(uint256 _jobId) public view returns (uint256, string memory, string memory, uint256, uint256, bool) {
        require(_jobId <= jobCount, "Invalid job ID");

        Job memory job = jobs[_jobId];
        return (job.id, job.title, job.description, job.salary, job.applicantId, job.isFilled);
    }

    // Function to get rating of an applicant
    function getApplicantRating(uint256 _applicantId) public view returns (uint256) {
        require(_applicantId <= applicantCount, "Invalid applicant ID");

        return applicants[_applicantId].rating;
    }

    // Function to get all applicants
    function getAllApplicants() public view returns (Applicant[] memory) {
        Applicant[] memory allApplicants = new Applicant[](applicantCount);
        for (uint256 i = 1; i <= applicantCount; i++) {
            allApplicants[i - 1] = applicants[i];
        }
        return allApplicants;
    }

    // Function to get the work preference of an applicant
    function getApplicantType(uint256 _applicantId) public view returns (WorkPreference) {
        require(_applicantId <= applicantCount, "Invalid applicant ID");

        return applicants[_applicantId].workPreference;
    }

    // Function to get all job details
    function getAllJobDetails() public view returns (Job[] memory) {
        Job[] memory allJobs = new Job[](jobCount);
        for (uint256 i = 1; i <= jobCount; i++) {
            allJobs[i - 1] = jobs[i];
        }
        return allJobs;
    }
}
