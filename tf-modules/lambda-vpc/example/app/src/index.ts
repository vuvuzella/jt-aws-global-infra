export const handler = (event: any, context: any) => {
  console.log('Execute handler');
  console.log(JSON.stringify(event));
  console.log(JSON.stringify(context));
}
