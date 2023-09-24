// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
contract practice{
    struct Student{
        uint roll;
        string name;
        uint[3] marks;
    
    }
    address Teacher;
    uint public stdCount;
    mapping(uint=> Student) public stdRecords;

    constructor(){
        Teacher=msg.sender;

    }
    modifier onlyTeachers{
        require(Teacher == msg.sender,"You are not Teacher");
        _;
   }
    function addRecord(uint _roll,string memory _name,uint[3] memory _marks) public onlyTeachers {
        stdRecords[_roll]= Student(_roll,_name,_marks);
    }
    function getRecord(uint _roll) public onlyTeachers view returns (Student memory){
        require (stdRecords[_roll].roll!=0,"record doesnot exist");
        return stdRecords[_roll];
    }
    function deleteRecords(uint _roll) public onlyTeachers{
        delete stdRecords[_roll];
    }
    





}
