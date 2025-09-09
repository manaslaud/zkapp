use poseidon::poseidon2;

/**
   Returns age in years.
   Assumes valid dates and current date >= birth date.
*/
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
    current_year: pub u32,
    current_month: pub u32,
    current_day: pub u32,
    min_age: pub u32,
    issuer: pub Field, // Issuer's uid
    expected_commitment: pub Field, // Poseidon2 commitment issues by issuer, it is static
    challenge: pub Field
) -> pub Field {

    // Step 1: Age check
    let age = calculate_age(
        birth_year, birth_month, birth_day,
        current_year, current_month, current_day
    );
    assert(age >= min_age);

    // Step 2: Commitment check
    // Combine all private credentials into a single Poseidon2 hash
    let static_commitment = poseidon2::Poseidon2::hash([nationality, address, student_status, issuer],4);
    assert(static_commitment == expected_commitment);

    let session_commitment = poseidon2::Poseidon2::hash([static_commitment, challenge],2);
    session_commitment
}


#[test]
fn test_calculate_age() {
    assert(calculate_age(2000, 1, 1, 2024, 1, 1) == 24);
}
#[test]
fn test_main() {
    // --------------------------
    // Private inputs
    // --------------------------
    let birth_year: u32 = 2000;
    let birth_month: u32 = 1;
    let birth_day: u32 = 1;
    let nationality: Field = 12345;       // Example field value
    let address: Field = 67890;           // Example field value
    let student_status: Field = 1;        // Student

    // --------------------------
    // Public inputs
    // --------------------------
    let current_year: u32 = 2024;
    let current_month: u32 = 9;
    let current_day: u32 = 9;
    let min_age: u32 = 18;
    let issuer: Field = 999;          // Example university ID

    // Calculate static commitment to simulate university-issued credential
    let expected_commitment: Field = poseidon2::Poseidon2::hash(
        [nationality, address, student_status, issuer],
        4
    );

    // Challenge for replay protection (verifier nonce)
    let challenge: Field = 5555;

    // --------------------------
    // Call main function
    // --------------------------
    let session_commitment = main(
        birth_year,
        birth_month,
        birth_day,
        nationality,
        address,
        student_status,
        current_year,
        current_month,
        current_day,
        min_age,
        issuer,
        expected_commitment,
        challenge
    );

    // --------------------------
    // Verify session commitment manually
    // --------------------------
    let expected_session_commitment = poseidon2::Poseidon2::hash(
        [expected_commitment, challenge],
        2
    );

    assert(session_commitment == expected_session_commitment);
}
