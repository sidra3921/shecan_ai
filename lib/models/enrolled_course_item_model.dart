import 'course_enrollment_model.dart';
import 'course_model.dart';

class EnrolledCourseItemModel {
  final CourseModel course;
  final CourseEnrollmentModel enrollment;

  EnrolledCourseItemModel({
    required this.course,
    required this.enrollment,
  });
}
