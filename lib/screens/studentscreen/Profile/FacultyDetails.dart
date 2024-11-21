import 'package:flutter/material.dart';

class FacultyDetails {
  // Define faculties and their associated programs
  static const Map<String, List<String>> facultiesAndPrograms = {
    "Faculty of Shariah and Islamic Studies": [
      "Qur’anic Sciences and Islamic Studies (QSIS)",
      "Da’wah & Islamic Studies (DIS)",
      "Science of Hadith and Islamic Studies (SHIS)",
    ],
    "Faculty of Law": [
      "Department of Law",
    ],
    "Faculty of Social Sciences": [
      "Economics & Banking",
    ],
    "Faculty of Science and Engineering": [
      "Computer Science And Engineering (CSE)",
      "Computer And Communication Engineering (CCE)",
      "Electrical And Electronic Engineering (EEE)",
      "Electronic And Telecommunication Engineering (ETE)",
      "Civil Engineering (CE)",
      "Pharmacy",
    ],
    "Faculty of Arts and Humanities": [
      "English Language and Literature (ELL)",
      "Arabic Language and Literature (ALL)",
      "Library and Information Science (LIS)",
    ],
    "Faculty of Business Studies": [
      "Business Administration",
    ],
  };

  // Method to get programs based on selected faculty
  static List<String> getPrograms(String faculty) {
    return facultiesAndPrograms[faculty] ?? [];
  }

  // Method to get all faculties
  static List<String> getAllFaculties() {
    return facultiesAndPrograms.keys.toList();
  }
}