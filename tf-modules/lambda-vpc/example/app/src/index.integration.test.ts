import { handler as sut } from './index';

describe('Integration test for lambda', () => {
  
  it('should make an http call successfully', async () => {
    const result = await sut(undefined, undefined);
    console.log(result.body);
    expect(result.statusCode).toBe(200);
  });

});
