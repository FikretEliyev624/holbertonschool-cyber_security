# Class implementing the Caesar Cipher encryption and decryption
class CaesarCipher
  # Initializes the cipher with a specific shift value
  def initialize(shift)
    @shift = shift
  end

  # Encrypts a plaintext message by applying the positive shift
  def encrypt(message)
    cipher(message, @shift)
  end

  # Decrypts a ciphertext message by reversing the shift (negative shift)
  def decrypt(message)
    cipher(message, -@shift)
  end

  private

  # Core method to shift characters, accessible only within the instance
  def cipher(message, shift)
    message.chars.map do |char|
      if char.match?(/[a-z]/)
        # Shift lowercase letters within 'a'..'z' (ASCII 97..122)
        ((char.ord - 97 + shift) % 26 + 97).chr
      elsif char.match?(/[A-Z]/)
        # Shift uppercase letters within 'A'..'Z' (ASCII 65..90)
        ((char.ord - 65 + shift) % 26 + 65).chr
      else
        # Keep punctuation, spaces, and numbers intact
        char
      end
    end.join
  end
end
