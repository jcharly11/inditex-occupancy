import 'package:test/test.dart'; 
import 'package:inditex_occupancy/longitud.dart'; 

void main() {
  group('Validacion de ID de regalo', () {
    test('Cadena valida con 24 caracteres en mayuscula y numeros', () {
      expect(validation('C10012505112080825122915'), true);
    });

    test('Cadena invalida con menos de 24 caracteres', () {
      expect(validation('ABC123'), isFalse);
    });

    test('Cadena invalida con letras minusculas', () {
      expect(validation('abcdef123456ghijkl7890mnop'), isFalse);
    });

    test('Cadena invalida con simbolos', () {
      expect(validation('ABCDEF123456GHIJKL7890M@OP'), isFalse);
    });

    test('Cadena invalida con espacios', () {
      expect(validation('ABCDEF123456 GHIJKL7890MNOP'), isFalse);
    });
  });
}
