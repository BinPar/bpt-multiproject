const testRegex = '(/tests/.*|(\\.|/)(test|spec))\\.(jsx?|js?|tsx?|ts?)$'

module.exports = {
  testRegex: testRegex,
  transform: {
    '^.+\\.js$': require.resolve('babel-jest'),
    '^.+\\.ts$': 'ts-jest'
  },
  testPathIgnorePatterns: ['<rootDir>/node_modules/', '<rootDir>/prod_node_modules/'],
  moduleFileExtensions: ['ts', 'js'],
};