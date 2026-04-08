import { RouterProvider } from 'react-router';
import { router } from './routes';
import { BudgetProvider } from './context/BudgetContext';

export default function App() {
  return (
    <BudgetProvider>
      <RouterProvider router={router} />
    </BudgetProvider>
  );
}