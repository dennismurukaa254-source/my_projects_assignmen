import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= SPLASH SCREEN =================

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              "Student Management App",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text("Get Started"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= LOGIN PAGE =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth * 0.85,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: usernameController,
                  decoration:
                  const InputDecoration(
                    labelText: "Username",
                    border:
                    OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:
                  const InputDecoration(
                    labelText: "Password",
                    border:
                    OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text(
                      "Login",
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const HomePage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= HOME PAGE =================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget dashboardCard(
      String title,
      String value,
      Color color) {
    return Card(
      color: color,
      child: SizedBox(
        width: 110,
        height: 100,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "Welcome to Student Management App",
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment:
                  WrapAlignment.center,
                  children: [
                    dashboardCard(
                      "Students",
                      "120",
                      Colors.blue,
                    ),
                    dashboardCard(
                      "Courses",
                      "15",
                      Colors.orange,
                    ),
                    dashboardCard(
                      "Departments",
                      "5",
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    child: const Text(
                        "Register Student"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const StudentRegistrationPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    child: const Text(
                        "View Records"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const ViewStudentPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    child:
                    const Text("Logout"),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const LoginPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= REGISTRATION PAGE =================

class StudentRegistrationPage
    extends StatefulWidget {
  const StudentRegistrationPage(
      {super.key});

  @override
  State<StudentRegistrationPage>
  createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState
    extends State<
        StudentRegistrationPage> {
  final nameController =
  TextEditingController();

  final admissionController =
  TextEditingController();

  final courseController =
  TextEditingController();

  final emailController =
  TextEditingController();

  Future<void> saveStudent() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setString(
        "studentName",
        nameController.text);

    await prefs.setString(
        "admissionNumber",
        admissionController.text);

    await prefs.setString(
        "course",
        courseController.text);

    await prefs.setString(
        "email",
        emailController.text);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Student Saved Successfully",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Student Registration"),
        backgroundColor:
        Colors.orange,
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller:
              nameController,
              decoration:
              const InputDecoration(
                labelText:
                "Student Name",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
              admissionController,
              decoration:
              const InputDecoration(
                labelText:
                "Admission Number",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
              courseController,
              decoration:
              const InputDecoration(
                labelText: "Course",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
              emailController,
              decoration:
              const InputDecoration(
                labelText:
                "Email Address",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                await saveStudent();
              },
              child: const Text(
                  "Save Student"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const ViewStudentPage(),
                  ),
                );
              },
              child: const Text(
                  "View Saved Record"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= VIEW STUDENT PAGE =================

class ViewStudentPage
    extends StatefulWidget {
  const ViewStudentPage(
      {super.key});

  @override
  State<ViewStudentPage>
  createState() =>
      _ViewStudentPageState();
}

class _ViewStudentPageState
    extends State<ViewStudentPage> {
  String studentName = "";
  String admissionNumber = "";
  String course = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  Future<void> loadStudent() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    setState(() {
      studentName =
          prefs.getString(
              "studentName") ??
              "";

      admissionNumber =
          prefs.getString(
              "admissionNumber") ??
              "";

      course =
          prefs.getString("course") ??
              "";

      email =
          prefs.getString("email") ??
              "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Saved Student Record"),
        backgroundColor:
        Colors.purple,
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              "Student Name: $studentName",
              style: const TextStyle(
                  fontSize: 20),
            ),

            const SizedBox(height: 15),

            Text(
              "Admission Number: $admissionNumber",
              style: const TextStyle(
                  fontSize: 20),
            ),

            const SizedBox(height: 15),

            Text(
              "Course: $course",
              style: const TextStyle(
                  fontSize: 20),
            ),

            const SizedBox(height: 15),

            Text(
              "Email: $email",
              style: const TextStyle(
                  fontSize: 20),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
              const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}