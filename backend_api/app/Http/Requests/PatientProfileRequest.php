<?php

namespace App\Http\Requests;

/**
 * PatientProfileRequest kế thừa trực tiếp từ StoreBenhNhanRequest
 * để đảm bảo toàn bộ quy tắc nghiệp vụ y tế chuyên sâu (BHYT, CCCD Cross-check, Trẻ em < 14)
 * được áp dụng đồng bộ trong toàn bộ hệ thống API.
 */
class PatientProfileRequest extends StoreBenhNhanRequest
{
    // Kế thừa toàn bộ authorize(), rules(), withValidator(), messages() từ StoreBenhNhanRequest
}
