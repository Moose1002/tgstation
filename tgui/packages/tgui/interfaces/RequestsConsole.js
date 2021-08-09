import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const RequestsConsole = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={400}
      height={305}>
      <Window.Content scrollable>
        <Section
          title="Messages"
          buttons={
            <Button
              icon={data.silent ? 'volume-mute' : 'volume-up'}
              selected={!data.silent}
              onClick={() => act('silence')}/>
          }>
            <Button
              content="Request Assistance"/>
            <Box mt={1} />
            <Button
              content="Request Supplies"/>
            <Box mt={1} />
            <Button
              content="View Messages"/>
            <Box mt={1} />
        </Section>
        <Section
          title="Emergencies"
        >
        </Section>

      </Window.Content>
    </Window>
  );
};
