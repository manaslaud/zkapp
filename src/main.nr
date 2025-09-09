use poseidon::poseidon2;
// Calculate age from birthdate and current date
fn calculate_age(
    birth_year: u32, birth_month: u32, birth_day: u32,
    current_year: u32, current_month: u32, current_day: u32
) -> u32 {
    let mut age: u32 = current_year - birth_year;

    // Before birthday this year?
    let before_birthday: bool =
        (current_month < birth_month) |
        ((current_month == birth_month) & (current_day < birth_day));

    if before_birthday {
        age = age - 1;
    }

    age
}

fn main(
    // ---- private inputs ----
    birth_year: u32,
    birth_month: u32,
    birth_day: u32,
    nationality: Field,
    address: Field,            // raw address committed as a field
    student_status: Field,     // 1 = student, 0 = not student

    // ---- public inputs ----
    current_year: u32,
    current_month: u32,
    current_day: u32,
    min_age: u32,
    expected_commitment: Field // Poseidon2 commitment from verifier
) {
    // Step 1: Age check
    let age = calculate_age(
        birth_year, birth_month, birth_day,
        current_year, current_month, current_day
    );
    assert(age >= min_age);

    // Step 2: Commitment check
    // Combine all private credentials into a single Poseidon2 hash
    let commitment = poseidon2::Poseidon2::hash([nationality, address, student_status],4);
    assert(commitment == expected_commitment);
}


#[test]
fn test_calculate_age() {
    assert(calculate_age(2000, 1, 1, 2024, 1, 1) == 24);
}