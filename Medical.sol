// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedicalRecords {
    struct Doctor {
        string name;
        string qualification;
        string workPlace;
    }

    struct Patient {
        uint256 id;
        string name;
        uint256 age;
        uint256[] diseases;
        address doctor;
    }

    struct Medicine {
        uint256 id;
        string name;
        uint256 expiryDate;
        string dose;
        uint256 price;
    }

    mapping(address => Doctor) public doctors;
    uint256 public totalDoctors;

    mapping(address => Patient) public patients;
    uint256 public totalPatients;

    mapping(uint256 => Medicine) public medicines;
    uint256 public totalMedicines;

    mapping(address => uint256[]) public prescribedMedicines;

    constructor() {
        totalDoctors = 0;
        totalPatients = 0;
        totalMedicines = 0;
    }

    modifier onlyDoctor() {
        require(bytes(doctors[msg.sender].name).length > 0, "Only registered doctors can access this function.");
        _;
    }

    function registerDoctor(string memory _name, string memory _qualification, string memory _workPlace) external {
        totalDoctors++;
        doctors[msg.sender] = Doctor(_name, _qualification, _workPlace);
    }

    function registerPatient(string memory _name, uint256 _age) external {
        totalPatients++;
        patients[msg.sender] = Patient(totalPatients, _name, _age, new uint256[](0), address(0));
    }

    function addNewDisease(string memory _disease) external onlyDoctor {
        require(bytes(patients[msg.sender].name).length > 0, "Only registered doctors can add diseases.");
        totalMedicines++;
        medicines[totalMedicines] = Medicine(totalMedicines, _disease, 0, "", 0);
        patients[msg.sender].diseases.push(totalMedicines);
    }

    function addMedicine(string memory _name, uint256 _expiryDate, string memory _dose, uint256 _price) external onlyDoctor {
        totalMedicines++;
        medicines[totalMedicines] = Medicine(totalMedicines, _name, _expiryDate, _dose, _price);
    }

    function prescribeMedicine(uint256 _medicineId, address _patient) external onlyDoctor {
        require(bytes(patients[_patient].name).length > 0, "Patient not found.");
        prescribedMedicines[_patient].push(_medicineId);
    }

    function updateAge(uint256 _age) external {
        require(bytes(patients[msg.sender].name).length > 0, "Only registered patients can update their age.");
        patients[msg.sender].age = _age;
    }

    function viewDoctorById(address _doctorAddress) external view returns (string memory, string memory, string memory) {
        Doctor storage doctor = doctors[_doctorAddress];
        require(bytes(doctor.name).length > 0, "Doctor not found.");
        return (doctor.name, doctor.qualification, doctor.workPlace);
    }

    function viewMedicine(uint256 _medicineId) external view returns (string memory, uint256, string memory, uint256) {
        Medicine storage medicine = medicines[_medicineId];
        require(medicine.id != 0, "Medicine not found.");
        return (medicine.name, medicine.expiryDate, medicine.dose, medicine.price);
    }

    function viewPatientByDoctor(address _patientAddress) external view onlyDoctor returns (uint256, string memory, uint256, uint256[] memory, address) {
        Patient storage patient = patients[_patientAddress];
        require(bytes(patient.name).length > 0, "Patient not found.");
        return (patient.id, patient.name, patient.age, patient.diseases, patient.doctor);
    }

    function viewPrescribedMedicine(address _patient) external view onlyDoctor returns (uint256[] memory) {
        return prescribedMedicines[_patient];
    }

    function ViewRecord() external view returns (uint256, string memory, uint256, uint256[] memory, address, uint256[] memory) {
        Patient storage patient = patients[msg.sender];
        require(bytes(patient.name).length > 0, "Patient not found.");
        return (patient.id, patient.name, patient.age, patient.diseases, patient.doctor, prescribedMedicines[msg.sender]);
    }
}
