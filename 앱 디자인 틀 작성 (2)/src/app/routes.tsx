import { createBrowserRouter } from 'react-router';
import { LoginPage } from './pages/LoginPage';
import { OnboardingMBTI } from './pages/OnboardingMBTI';
import { OnboardingSetup } from './pages/OnboardingSetup';
import { DashboardPage } from './pages/DashboardPage';
import { LedgerPage } from './pages/LedgerPage';
import { CharacterPage } from './pages/CharacterPage';
import { DangerZonePage } from './pages/DangerZonePage';
import { AppLayout } from './components/AppLayout';

export const router = createBrowserRouter([
  { path: '/', Component: LoginPage },
  { path: '/onboarding/mbti', Component: OnboardingMBTI },
  { path: '/onboarding/setup', Component: OnboardingSetup },
  {
    Component: AppLayout,
    children: [
      { path: '/home', Component: DashboardPage },
      { path: '/ledger', Component: LedgerPage },
      { path: '/character', Component: CharacterPage },
      { path: '/danger', Component: DangerZonePage },
    ],
  },
]);
