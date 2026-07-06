import collisionSystemTest from '../ohosTest/ets/test/CollisionSystem.test';
import interactionFeedbackTest from '../ohosTest/ets/test/InteractionFeedback.test';
import interactionSystemTest from '../ohosTest/ets/test/InteractionSystem.test';
import movementControllerTest from '../ohosTest/ets/test/MovementController.test';
import questSystemTest from '../ohosTest/ets/test/QuestSystem.test';

export default function testsuite() {
  collisionSystemTest();
  interactionFeedbackTest();
  interactionSystemTest();
  movementControllerTest();
  questSystemTest();
}
