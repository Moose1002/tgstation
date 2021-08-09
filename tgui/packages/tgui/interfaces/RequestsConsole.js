import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, LabeledList, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const RequestsConsole = (props, context) => {
  const [tab, setTab] = useLocalState(context, 'tab', "messages");
  return (
    <Window
      width={400}
      height={305}>
      <Window.Content scrollable>
        <Section fitted>
          <Tabs>
              <Tabs.Tab
                selected={tab === "messages"}
                onClick={() => setTab("messages")}>
                Messages
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "request"}
                onClick={() => setTab("request")}>
                Request
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "emergency"}
                onClick={() => setTab("emergency")}>
                Emergencies
              </Tabs.Tab>
          </Tabs>
          </Section>
          {tab === "messages" && (
            <RequestsConsoleMessages />
          )}
          {tab === "request" && (
            <RequestsConsoleRequest />
          )}
          {tab === "emergency" && (
            <RequestsConsoleEmergencies />
          )}
      </Window.Content>
    </Window>
  );
};

export const RequestsConsoleMessages = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Messages"
      buttons={
        <Button
          icon={data.silent ? 'volume-mute' : 'volume-up'}
          selected={!data.silent}
          onClick={() => act('silence')}/>
        }>
    </Section>
  );
};

export const RequestsConsoleRequest = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Request Console">
      <DepartmentDropdown/>
      <Button
        content="Normal Priority"/>
      <Button
        content="High Priority"/>
    </Section>
  );
};

export const RequestsConsoleEmergencies = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Emergencies"
        >
    </Section>
  );
};

export const DepartmentDropdown = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Stack>
      <Stack.Item grow>
        <Dropdown
          width="75%"
          selected={data.recipientDepartment ? data.recipientDepartment : "Recipient Department..."}
          options={data.assistanceDepartments}
          onSelected={sel => act("to_department", {
            department: sel,
          })} />
      </Stack.Item>
    </Stack>
  );
};
