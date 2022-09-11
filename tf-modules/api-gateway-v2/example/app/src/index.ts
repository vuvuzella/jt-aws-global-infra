import axios from 'axios';
import { fromPromise } from 'neverthrow';

const getFromApi = (
  uri: string,
  headers?: {[key: string]: string},
  queryParams?: {[key: string]: string}
  ) => {
  const getResult = fromPromise(axios.get(uri, {
    headers: {
      Accept: 'application/json'
    }
  }),
    e => new Error(`Error in axios.get: ${JSON.stringify(e)}`))
  return getResult;
}

export const handler = async (event: any, context: any) => {
  console.log('Execute handler');
  console.log(JSON.stringify(event));
  console.log(JSON.stringify(context));
  
  const publicApi = 'https://api.coindesk.com/v1/bpi/currentprice.json';
  console.log(`Making an API call to ${publicApi}`);
  
  const getResult = await getFromApi(publicApi);
  
  if (getResult.isErr()) {
    return {
      statusCode: 500,
      body: JSON.stringify({
      error: getResult.error.message})
    };
  }
  
  console.log(`Api getResult: ${JSON.stringify(getResult.value.data)}`);
  
  return {
    statusCode: getResult.value.status,
    body: getResult.value.data
  };
  
}
